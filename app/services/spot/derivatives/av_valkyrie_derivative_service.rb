# frozen_string_literal: true
module Spot
  module Derivatives
    # Checks the 'premade_derivatives' property on the associated work. If the property is empty,
    # generates derivatives (mp3 for audio) and sends them to an s3 bucket. If
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
    class AvValkyrieDerivativeService < BaseDerivativeService
      # Checks for premade derivatives, calls for derivative generation if none exist.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_derivatives(filename)
        if audio_mime_types.include?(mime_type)
          create_audio_derivative_files(filename)
        else
          create_video_derivative_files(filename)
        end
      end

      def cleanup_derivatives
        derivative_path_factory.derivatives_for_reference(file_set).each do |path|
          FileUtils.rm_f(path)
        end
      end

      # The destination_name parameter has to match up with the file parameter
      # passed to the DownloadsController
      def derivative_url(destination_name)
        path = derivative_path_factory.derivative_path_for_reference(derivative_url_target, destination_name)
        URI("file://#{path}").to_s
      end

      # only run service if bucket is defined and file includes audio mime types
      def valid?
        (audio_mime_types.include?(mime_type) || video_mime_types.include?(mime_type)) && Hyrax.config.use_valkyrie?
      end

      private

      # Uses Hydra to create one mp3 derivative of the original file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_audio_derivative_files(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'mp3', format: 'mp3', url: derivative_url('mp3') }])
      end

      # Uses Hydra to create one mp4 and one ogg derivative of the original file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_video_derivative_files(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'webm',
                                                                format: 'webm',
                                                                url: derivative_url('webm'),
                                                                size: get_derivative_resolution(filename, 480),
                                                                mime_type: 'video/webm',
                                                                input_options: "-ss 1",
                                                                video: "-g 30 -b:v 2500k",
                                                                audio: "-b:a 256k -ar 44100" },
                                                              { label: 'mp4',
                                                                format: 'mp4',
                                                                url: derivative_url('mp4'),
                                                                size: get_derivative_resolution(filename, 1080),
                                                                mime_type: 'video/mp4',
                                                                input_options: "-ss 1",
                                                                video: "-g 30 -b:v 8000k",
                                                                audio: "-b:a 256k -ar 44100" }])
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

      # If given a FileMetadata object pass the file_set_id for derivative URL
      # creation.
      def derivative_url_target
        if file_set.try(:file_set_id)
          file_set.file_set_id.to_s
        else
          file_set
        end
      end

      def derivative_path_factory
        Hyrax::DerivativePath
      end
    end
  end
end
