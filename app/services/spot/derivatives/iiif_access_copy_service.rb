# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'

module Spot
  module Derivatives
    # Creates pyramidal TIFF copies of Images for serving via IIIF. Pyramidal TIFFs contain
    # layers at different resolutions which makes their use in a deep-zooming IIIF application
    # (ie. UniversalViewer) more efficient.
    #
    # This generates the file locally and then uploads to an S3 bucket defined by the
    # AWS_IIIF_ASSET_BUCKET environment variable. The local copy is deleted afterwards.
    #
    # These derivatives are created for an FileSets that include Image mime_types.
    #
    # @see https://www.loc.gov/preservation/digital/formats/fdd/fdd000237.shtml
    class IiifAccessCopyService < BaseDerivativeService
      class_attribute :derivative_key_template
      self.derivative_key_template = '%s-access.tif'

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
        output_dirname = File.dirname(derivative_path)
        FileUtils.mkdir_p(output_dirname) unless File.directory?(output_dirname)

        MiniMagick::Tool::Convert.new do |convert|
          convert.merge!(
            [
              "#{filename}[0]",
              "-define", "tiff:tile-geometry=128x128",
              "-compress", "jpeg",
              "ptif:#{derivative_path}"
            ]
          )
        end

        upload_derivative_to_s3

        FileUtils.rm_f(derivative_path) if File.exist?(derivative_path)
      end

      # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
      # but modifies the filename it writes out to.
      #
      # @return [String]
      def derivative_path
        @derivative_path ||=
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access.tif').to_s.gsub(/\.access\.tif$/, '')
      end

      # Only create pyramidal TIFFs if the source mime_type is an Image and if we defined
      def valid?
        if s3_bucket.blank?
          Rails.logger.warn('Skipping IIIF Access Copy generation because the AWS_IIIF_ASSET_BUCKET environment variable is not defined.')
          return false
        end

        image_mime_types.include?(mime_type)
      end

      private

      def s3_bucket
        ENV['AWS_IIIF_ASSET_BUCKET']
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
          metadata: {
            'width' => file_set.width.first,
            'height' => file_set.height.first
          }
        )
      end
    end
  end
end
