# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'
require 'ffprober'

module Spot
  module Derivatives
    # Checks the 'premade_derivatives' property on the associated work. If the property is empty,
    # generates derivatives (mp3 and mp4 for audio and video) and sends them to an s3 bucket. If
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
    class AudioVisualDerivativeCopyService < BaseDerivativeService
      # Deletes the derivative from the S3 bucket
      # @todo maybe we should hang onto these when we delete + put them in a glacier grave?
      # @return [void]
      # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#delete_object-instance_method
      def cleanup_derivatives
        stored_derivatives = file_set.parent.stored_derivatives.to_a
        stored_derivatives.each do |derivative|
          s3_client.delete_object(bucket: s3_bucket, key: derivative)
        end
      end

      # Generates a pyramidal TIFF using ImageMagick (via MiniMagick gem)
      # and uploads it to the S3 bucket.
      #
      # @param [String,Pathname] filename the src path of the file
      # @return [void]
      def create_derivatives(filename)
        return if check_premade_derivatives(filename)

        if audio_mime_types.include?(mime_type)
          create_audio_derivatives(filename)
        else
          create_video_derivatives(filename)
        end

        upload_derivatives_to_s3(s3_derivative_keys, derivative_paths)
        derivative_paths.each do |path|
          FileUtils.rm_f(path) if File.exist?(path)
        end
      end

      # Check to see if any premade derivatives exist, process them if so.
      #
      # @return [Boolean]
      def check_premade_derivatives(filename)
        premade_derivatives = file_set.parent.premade_derivatives.to_a

        return false if premade_derivatives.empty?

        premade_derivatives.each do |derivative|
          key = '%s-access.mp3' % file_set.id
          if video_mime_types.include?(mime_type)
            res = get_video_resolution(filename)
            key = '%s-access-%d.mp4' % [file_set.id, res[1]]
          end
          transfer_s3_derivative(derivative, key)
        end
        true
      end

      def get_video_resolution(filename)
        ffprobe = Ffprober::Parser.from_file(filename)
        [ffprobe.video_streams[0].width, ffprobe.video_streams[0].height]
      end

      def get_derivative_resolution(filename, height)
        res = get_video_resolution(filename)
        width = res[0]*height
        width = width/res[1]
        if width%16 > 0 
          width = width - width%16 + 16 
        end
        '%dx%d' % [width, height]
      end

      def derivative_paths
        if audio_mime_types.include?(mime_type)
          [Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access.mp3').to_s.gsub(/\.access\.mp3$/, '')]
        else
          [Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access-high.mp4').to_s.gsub(/\.access-high\.mp4$/, ''), 
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access-low.mp4').to_s.gsub(/\.access-low\.mp4$/, '')]
        end
      end

      def derivative_urls
        ret = []
        derivative_paths.each do |path|
          ret.push(URI("file://#{path}").to_s)
        end
        ret
      end

      # Only create pyramidal TIFFs if the source mime_type is an Image and if we defined
      def valid?
        if s3_bucket.blank?
          Rails.logger.warn('Skipping audio derivative generation because the AWS_AUDIO_VISUAL_BUCKET environment variable is not defined.')
          return false
        end

        audio_mime_types.include?(mime_type) || video_mime_types.include?(mime_type)
      end

      private

      def create_audio_derivatives(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'mp3', format: 'mp3', url: derivative_urls[0] }])
      end

      def create_video_derivatives(filename)
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

      def s3_bucket
        ENV['AWS_BULKRAX_IMPORTS_BUCKET']
      end

      def s3_source
        ENV['AWS_BULKRAX_IMPORTS_BUCKET']
      end

      # We're using AWS credentials stored within the App/Sidekiq services for authentication,
      # so the Aws::S3::Client will pick them up ambiently.
      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      def s3_derivative_keys
        if audio_mime_types.include?(mime_type)
          ['%s-access.mp3' % file_set.id]
        else
          ['%s-access-1080.mp4' % file_set.id,
          '%s-access-480.mp4' % file_set.id]
        end
      end

      def upload_derivatives_to_s3(keys, paths)
        parent = file_set.parent
        stored_derivatives = []
        paths.each_with_index do |path, index|
          stored_derivatives.push(keys[index])
          s3_client.put_object(
            bucket: s3_bucket,
            key: keys[index],
            body: File.open(path, 'r'),
            content_length: File.size(path),
            content_md5: Digest::MD5.file(path).base64digest,
            metadata: {}
          )
        end
        parent.stored_derivatives = stored_derivatives
        parent.save
      end

      def transfer_s3_derivative(derivative, key)
        parent = file_set.parent
        stored_derivatives = parent.stored_derivatives.to_a
        stored_derivatives.push(key)
        parent.stored_derivatives = stored_derivatives
        parent.save
        src = "/" + s3_source + "/" + derivative
        s3_client.copy_object(
          bucket: s3_bucket,
          copy_source: src,
          key: s3_derivative_key[index]
        )
      end
    end
  end
end
