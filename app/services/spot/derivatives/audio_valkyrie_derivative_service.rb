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
    class AudioValkyrieDerivativeService < BaseDerivativeService
      # Checks for premade derivatives, calls for derivative generation if none exist.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_derivatives(filename)
        create_derivative_files(filename)
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
        audio_mime_types.include?(mime_type) && Hyrax.config.use_valkyrie?
      end

      private

      # Uses Hydra to create one mp3 derivative of the original file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_derivative_files(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'mp3', format: 'mp3', url: derivative_url('mp3') }])
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
