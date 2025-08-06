# frozen_string_literal: true
require 'fileutils'

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
module Spot
  module Derivatives
    module IiifAccessCopyBehavior
      # Create a pyramidal tiff derivative from the pathname provided
      # and upload it to our IIIF S3 bucket with the name `<file_set.id>-access.tif`.
      # The intermediary file is deleted after upload.
      def create_and_upload_iiif_access_copy(filename)
        if ENV['AWS_IIIF_ASSET_BUCKET'].blank?
          Rails.logger.warn('Skipping IIIF Access Copy generation because the AWS_IIIF_ASSET_BUCKET environment variable is not defined.')
          return false
        end

        create_access_copy_from(filename)
        upload_derivatives_to_s3 && FileUtils.rm_f(shuttle_file) if File.exist?(shuttle_file)
      end

      # Deletes the derivative from the S3 bucket using the Valkyrie storage adapter
      #
      # @todo maybe we should hang onto these when we delete + put them in a glacier grave?
      # @return [void]
      def delete_iiif_access_copy!
        storage_adapter.delete(id: File.basename(shuttle_file))
      end

      private

      def create_access_copy_from(src)
        MiniMagick::Tool::Convert.new do |convert|
          convert.merge!(
            [
              "#{src}[0]",
              "-define", "tiff:tile-geometry=128x128",
              "-compress", "jpeg",
              "ptif:#{shuttle_file}"
            ]
          )
        end
      end

      def shuttle_file
        working_directory.join("#{file_set.id}-access.tif")
      end

      def storage_adapter
        Valkyrie::StorageAdapter.find(:iiif_source_s3)
      end

      def upload_derivatives_to_s3
        storage_adapter.upload(
          resource: file_set,
          file: File.open(shuttle_file),
          original_filename: File.basename(shuttle_file),
          metadata: {
            'width' => file_set.width.first,
            'height' => file_set.height.first
          }
        )
      end

      def working_directory
        @working_directory ||= Rails.root.join('tmp', 'iiif-src').tap do |src|
          FileUtils.mkdir_p(src) unless Dir.exist?(src)
        end
      end
    end
  end
end
