# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'
require 'ffprober'

module Spot
  module Derivatives
    # Checks the 'premade_derivatives' property on the associated work. If the property is empty,
    # generates derivatives (mp4 in 480p and 1080p for video) and sends them to an s3 bucket. If
    # the 'premade_derivatives' field is not empty, then moves the associated derivative to the
    # correct bucket with a new name.
    #
    # Derivatives are either generated locally and then posted to the s3 bucet defined by
    # the AWS_AUDIO_VISUAL_BUCKET environment variable, or they exist already and are moved from
    # the AWS_BULKRAX_IMPORTS_BUCKET to the AWS_AUDIO_VISUAL_BUCKET. Local copies are deleted afterwards.
    #
    # These derivatives are created for an FileSets that include Audio or Video mime_types.
    #
    # @see https://www.loc.gov/preservation/digital/formats/fdd/fdd000237.shtml
    class VideoDerivativeService < AudioVisualBaseDerivativeService
      # Checks for premade derivatives, calls for derivative generation if none exist.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_derivatives(filename)
        return if check_premade_derivatives

        create_derivative_files(filename)
        upload_derivatives_to_s3(s3_derivative_keys, derivative_paths)
        derivative_paths.each do |path|
          FileUtils.rm_f(path) if File.exist?(path)
        end
      end

      # Check to see if any premade derivatives exist, process them if so.
      #
      # @param [String] derivative, the s3 key of a premade derivative
      # @param [Integer] index, index of premade derivative in array
      # @return [void]
      def rename_premade_derivative(derivative, index)
        file_path = "/tmp/" + derivative
        s3_client.get_object(key: derivative, bucket: s3_source, response_target: file_path)
        res = get_video_resolution(file_path)
        # add any other checks to the file here
        key = format('%s-%d-access-%d.mp4', file_set.id, index, res[1])
        FileUtils.rm_f(file_path) if File.exist?(file_path)
        transfer_s3_derivative(derivative, key)
      end

      # Returns the resolution of a video file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [Array(Integer)] pair of two numbers representing the video's width and height
      def get_video_resolution(filename)
        ffprobe = Ffprober::Parser.from_file(filename)
        [ffprobe.video_streams[0].width, ffprobe.video_streams[0].height]
      end

      # Calculates the desired width of a video derivative given the desired height.
      # Rounded down to mod 16.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @param [Integer] height, desired height of the derivative in pixels
      # @return [String] string format of pair of two numbers representing the video's width and height
      def get_derivative_resolution(filename, height)
        res = get_video_resolution(filename)
        width = res[0] * height
        width /= res[1]
        width = width - width % 16 + 16 if (width % 16).positive?
        format('%dx%d', width, height)
      end

      # paths for generated derivatives
      def derivative_paths
        [Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access-high.mp4').to_s.gsub(/\.access-high\.mp4$/, ''),
         Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access-low.mp4').to_s.gsub(/\.access-low\.mp4$/, '')]
      end

      # only run service if bucket is defined and file includes video mime types
      def valid?
        if s3_bucket.blank?
          Rails.logger.warn('Skipping audio derivative generation because the AWS_AUDIO_VISUAL_BUCKET environment variable is not defined.')
          return false
        end

        video_mime_types.include?(mime_type)
      end

      private

      # Uses Hydra to create two derivatives of the original file,
      # both mp4s with one at 480p and one at 1080p.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_derivative_files(filename)
        Hydra::Derivatives::VideoDerivatives.create(filename,
                                                    outputs: [{ label: 'high',
                                                                format: 'mp4',
                                                                url: derivative_urls[0],
                                                                size: get_derivative_resolution(filename, 1080),
                                                                input_options: "-t 10 -ss 1",
                                                                video: "-g 30 -b:v 8000k",
                                                                audio: "-b:a 256k -ar 44100" },
                                                              { label: 'low',
                                                                format: 'mp4',
                                                                url: derivative_urls[1],
                                                                size: get_derivative_resolution(filename, 480),
                                                                input_options: "-t 10 -ss 1",
                                                                video: "-g 30 -b:v 2500k",
                                                                audio: "-b:a 256k -ar 44100" }])
      end

      # Keys for generated derivatives.
      def s3_derivative_keys
        [format('%s-0-access-1080.mp4', file_set.id),
         format('%s-1-access-480.mp4', file_set.id)]
      end
    end
  end
end
