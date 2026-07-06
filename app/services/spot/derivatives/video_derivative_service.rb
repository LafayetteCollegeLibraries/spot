# frozen_string_literal: true
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
        check_transcript(filename)
        return if check_premade_derivatives(filename)

        create_derivative_files(filename)
        upload_derivatives_to_s3(s3_derivative_keys, derivative_paths)
        derivative_paths.each do |path|
          FileUtils.rm_f(path) if File.exist?(path)
        end
      end

      # Check to see if any premade derivatives exist, process them if so.
      #
      # @return [Boolean]
      def check_premade_derivatives(filename)
        prefix = premade_derivative_key_with_suffix(filename, suffix: '_derivative')

        Hyrax.logger.debug("Derivative Prefix: #{prefix}")
        object_list = s3_client.list_objects(bucket: s3_source, prefix: prefix).to_h.fetch(:contents, nil)

        return false if object_list.nil?

        Hyrax.logger.debug("Derivative list size: #{object_list.length}")

        object_list.each_with_index do |obj, index|
          rename_premade_derivative(obj[:key], index)
        end

        true
      end

      # Check to see if any premade derivatives exist, process them if so.
      #
      # @param [String] derivative, the s3 key of a premade derivative
      # @param [Integer] index, index of premade derivative in array
      # @return [void]
      def rename_premade_derivative(derivative, index)
        file_path = Rails.root.join('tmp', 'premade_derivatives', derivative).to_s
        destination = File.dirname(file_path)

        FileUtils.mkdir_p(destination) unless Dir.exist?(destination)

        s3_client.get_object(key: derivative, bucket: s3_source, response_target: file_path)
        res = get_video_resolution(file_path)
        # add any other checks to the file here
        key = format('%s-%d-access-%d.mp4', file_set.id, index, res[1])
        FileUtils.rm_f(file_path) if File.exist?(file_path)
        transfer_s3_derivative(derivative, key)
      end

      # Checks if the file has an associated transcript on s3, enques the relevant job if so.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def check_transcript(filename)
        transcript_name = premade_derivative_key_with_suffix(filename, suffix: '_caption.vtt')
        Hyrax.logger.debug('Transcript Name: ' + transcript_name)

        begin
          s3_client.head_object(bucket: s3_source, key: transcript_name)
        rescue Aws::S3::Errors::NotFound
          Hyrax.logger.warn('Transcript not found.')
        else
          # enqueue job
          Spot::TranscriptJob.perform_later(file_set: file_set, transcript_name: transcript_name)
          Hyrax.logger.debug('Transcript job enqueued.')
        end
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
        return false if Hyrax.config.use_valkyrie?
        return no_bucket_warning if s3_bucket.blank?

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
                                                                input_options: "-ss 1",
                                                                video: "-g 30 -b:v 8000k",
                                                                audio: "-b:a 256k -ar 44100" },
                                                              { label: 'low',
                                                                format: 'mp4',
                                                                url: derivative_urls[1],
                                                                size: get_derivative_resolution(filename, 480),
                                                                input_options: "-ss 1",
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
