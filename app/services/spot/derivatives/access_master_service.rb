# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'

module Spot
  module Derivatives
    # Creates access_master derivatives for all image-based works.
    # Intended to be run as part of a subset within {Spot::ImageDerivativesService}
    # and needs to respond to :cleanup_derivatives and :create_derivatives (the
    # latter receives a source filename as a parameter).
    #
    # When the AWS_IIIF_ASSET_BUCKET environment variable is present, this will
    # write the file to that location and delete the local working copy.
    #
    # @example
    #   file_set = FileSet.find(id: 'abc123def')
    #   src_path = Rails.root.join('tmp', 'uploads', more_path, 'original-file.tif')
    #   Spot::Derivatives::AccessMasterService.new(file_set).create_derivatives(src_path)
    class AccessMasterService < BaseDerivativesService
      # Determines which cleanup method to use based on whether or not AWS related
      # variables are present in ENV
      #
      # @return [void]
      def cleanup_derivatives
        use_s3? ? cleanup_s3_derivatives : cleanup_local_derivatives
      end

      # Deletes the local access_master derivative if it exists
      #
      # @return [void]
      def cleanup_local_derivatives
        FileUtils.rm_f(derivative_path) if File.exist?(derivative_path)
      end

      # Deletes the derivative from the S3 bucket
      # @todo maybe we should hang onto these when we delete + put them in a glacier grave?
      # @return [void]
      # @see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#delete_object-instance_method
      def cleanup_s3_derivatives
        s3_client.delete_object(bucket: s3_bucket, key: s3_derivative_key)
      end

      # Since we want to pass some extended options to the creation process,
      # we'll use MiniMagick directly instead of Hydra::Derviatives::ImageDerivatives.
      # If AWS ENV variables are present, this will upload the generated file
      # to an S3 bucket and then delete the local copy.
      #
      # @param [String,Pathname] filename the src path of the file
      # @return [void]
      def create_derivatives(filename)
        output_dirname = File.dirname(derivative_path)
        FileUtils.mkdir_p(output_dirname) unless File.directory?(output_dirname)

        MiniMagick::Tool::Convert.new do |magick|
          magick << "#{filename}[0]"
          # note: we need to use an array for each piece of this command;
          # using a string will cause an error
          magick.merge! %w[-define tiff:tile-geometry=128x128 -compress jpeg]
          magick << "ptif:#{derivative_path}"
        end

        return unless use_s3?

        upload_derivative_to_s3 && cleanup_local_derivatives
      end

      # copied from https://github.com/samvera/hyrax/blob/5a9d1be1/app/services/hyrax/file_set_derivatives_service.rb#L32-L37
      # but modifies the filename it writes out to.
      #
      # @return [String]
      def derivative_path
        @derivative_path ||=
          Hyrax::DerivativePath.derivative_path_for_reference(file_set, 'access.tif').to_s.gsub(/\.access\.tif$/, '')
      end

      private

      def s3_bucket
        ENV['AWS_IIIF_ASSET_BUCKET']
      end

      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      def s3_derivative_key
        "#{file_set.id}-access.tif"
      end

      def upload_derivative_to_s3
        s3_client.put_object(
          bucket: s3_bucket,
          key: s3_derivative_key,
          body: File.open(derivative_path, 'r'),
          content_length: File.size(derivative_path),
          content_md5: Digest::MD5.file(derivative_path).base64digest
        )
      end

      def use_s3?
        s3_bucket.present?
      end
    end
  end
end
