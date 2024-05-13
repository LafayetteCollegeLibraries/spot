# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'

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
    class AudioDerivativeCopyService < BaseDerivativeService
      class_attribute :derivative_key_template
      self.derivative_key_template = '%s-access.mp3'

      # Deletes the derivative from the S3 bucket
      # @todo maybe we should hang onto these when we delete + put them in a glacier grave?
      # @return [void]
      # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#delete_object-instance_method
      def cleanup_derivatives
        s3_client.delete_object(bucket: s3_bucket, key: s3_derivative_key)
      end

      # Generates a pyramidal TIFF using ImageMagick (via MiniMagick gem)
      # and uploads it to the S3 bucket.
      #
      # @param [String,Pathname] filename the src path of the file
      # @return [void]
      def create_derivatives(filename)
        create_audio_derivatives(filename)

        upload_derivative_to_s3

        FileUtils.rm_f(derivative_path) if File.exist?(derivative_path)
      end

      # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
      # but modifies the filename it writes out to.
      #
      # @return [String]
      def derivative_path
        @derivative_path ||=
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access.mp3').to_s.gsub(/\.access\.mp3$/, '')
      end

      def derivative_url
        URI("file://#{derivative_path}").to_s
      end

      # Only create pyramidal TIFFs if the source mime_type is an Image and if we defined
      def valid?
        if s3_bucket.blank?
          Rails.logger.warn('Skipping IIIF Access Copy generation because the AWS_IIIF_ASSET_BUCKET environment variable is not defined.')
          return false
        end

        audio_mime_types.include?(mime_type)
      end

      private

      def create_audio_derivatives(filename)
        Hydra::Derivatives::AudioDerivatives.create(filename,
                                                    outputs: [{ label: 'mp3', format: 'mp3', url: derivative_url }])
      end

      def s3_bucket
        ENV['AWS_AUDIO_VISUAL_BUCKET']
      end

      # We're using AWS credentials stored within the App/Sidekiq services for authentication,
      # so the Aws::S3::Client will pick them up ambiently.
      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      def s3_derivative_key
        derivative_key_template % file_set.id
      end

      def upload_derivative_to_s3
        s3_client.put_object(
          bucket: s3_bucket,
          key: s3_derivative_key,
          body: File.open(derivative_path, 'r'),
          content_length: File.size(derivative_path),
          content_md5: Digest::MD5.file(derivative_path).base64digest,
          metadata: {}
        )
      end
    end
  end
end
