# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'
require 'ffprober'

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
    class AudioDerivativeService < AudioVisualBaseDerivativeService
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
      # @return [Boolean]
      def check_premade_derivatives
        premade_derivatives = file_set.parent.premade_derivatives.to_a
        stored_derivatives = file_set.parent.stored_derivatives.to_a

        return false if premade_derivatives.empty?
        return true if !stored_derivatives.empty?

        premade_derivatives.each_with_index do |derivative, index|
          rename_premade_derivative(derivative, index)
        end
        true
      end

      # Check to see if any premade derivatives exist, process them if so.
      #
      # @param [String] derivative, the s3 key of a premade derivative
      # @param [Integer] index, index of premade derivative in array
      # @return [void]
      def rename_premade_derivative(derivative, index)
        file_path = "/tmp/" + derivative
        s3_client.get_object(key: derivative, bucket: s3_source, response_target: file_path)
        # add any other checks to the file here
        key = format('%s-%d-access.mp3', file_set.id, index)
        FileUtils.rm_f(file_path) if File.exist?(file_path)
        transfer_s3_derivative(derivative, key)
      end

      # paths for generated derivatives
      def derivative_paths
        [Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access.mp3').to_s.gsub(/\.access\.mp3$/, '')]
      end

      # only run service if bucket is defined and file includes audio mime types
      def valid?
        if s3_bucket.blank?
          Rails.logger.warn('Skipping audio derivative generation because the AWS_AUDIO_VISUAL_BUCKET environment variable is not defined.')
          return false
        end

        audio_mime_types.include?(mime_type)
      end

      private

      # Uses Hydra to create one mp3 derivative of the original file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_derivative_files(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'mp3', format: 'mp3', url: derivative_urls[0] }])
      end

      # Keys for generated derivatives.
      def s3_derivative_keys
        [format('%s-0-access.mp3', file_set.id)]
      end
    end
  end
end
