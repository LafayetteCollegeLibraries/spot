# frozen_string_literal: true
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
    class ImageDerivativeService < BaseDerivativeService
      class_attribute :service_file_use, default: Hyrax::FileMetadata::Use::SERVICE_FILE

      # Deletes the derivative from the S3 bucket using the Valkyrie storage adapter
      # @todo maybe we should hang onto these when we delete + put them in a glacier grave?
      # @return [void]
      def cleanup_derivatives
        super

        find_service_files_from_file_set.each do |file|
          storage_adapter.delete(id: file.id)
        end
      end

      # Generates a pyramidal TIFF using ImageMagick (via MiniMagick gem)
      # and uploads it to the S3 bucket via Valkyrie StorageAdapter.
      #
      # @param [String,Pathname] filename the src path of the file
      # @return [void]
      # @todo do we delete the working copy or just let it hang in tmp/uploads?
      def create_derivatives(filename)
        super

        create_and_attach_iiif_access_copy(filename)
      end

      # Only create pyramidal TIFFs if the source mime_type is an Image and if we defined the bucket
      def valid?
        return no_bucket_warning if s3_bucket.blank?

        Hyrax.config.use_valkyrie? && image_mime_types.include?(mime_type)
      end

      private

      # Use Hyrax::ValkyrieUpload service (see #upload_service) to move the shuttle
      # file to S3, create a FileMetadata object for the file, and attach the
      # object to the file_set as a Hyrax::FileMetadata::Use::SERVICE_FILE.
      #
      # @return Hyrax::FileMetadata
      def attach_service_file_to_file_set
        upload_service.upload(
          filename: File.basename(shuttle_filename),
          file_set: file_set,
          mime_type: 'image/tiff',
          io: File.open(shuttle_filename),
          skip_derivatives: true,
          use: service_file_use,
          user: deposit_user
        )
      end

      # Create a pyramidal tiff derivative from the pathname provided
      # and upload it to our IIIF S3 bucket with the name `<file_set.id>-access.tif`.
      # The intermediary file is deleted after upload.
      def create_and_attach_iiif_access_copy(filename)
        return no_bucket_warning if s3_bucket.blank?

        create_access_copy_from(filename)
        attach_service_file_to_file_set && delete_shuttle_file!
      end

      def create_access_copy_from(src)
        MiniMagick::Tool::Convert.new do |convert|
          convert.merge!(
            [
              "#{src}[0]",
              "-define", "tiff:tile-geometry=128x128",
              "-compress", "jpeg",
              "ptif:#{shuttle_filename}"
            ]
          )
        end
      end

      def delete_shuttle_file!
        FileUtils.rm_f(shuttle_filename) if File.exist?(shuttle_filename)
      end

      def deposit_user
        User.find_or_create_system_user(Hyrax.config.system_user_key)
      end

      def find_service_file_from_file_set
        Hyrax.query_service
             .custom_queries
             .find_many_file_metadata_from_ids(ids: file_set.file_ids)
             .select { |file| file.pcdm_use.include?(service_file_use) }
      end

      def no_bucket_warning
        Rails.logger.warn('Skipping IIIF Access Copy generation because the AWS_IIIF_ASSET_BUCKET environment variable is not defined.')
        false
      end

      def s3_bucket
        ENV['AWS_IIIF_ASSET_BUCKET']
      end

      def shuttle_filename
        working_directory.join("#{file_set.id}-access.tif")
      end

      def iiif_storage_adapter
        Valkyrie::StorageAdapter.find(:iiif_source_s3)
      end

      def upload_service
        Hyrax::ValkyrieUpload.new(storage_adapter: iiif_storage_adapter)
      end

      def working_directory
        @working_directory ||= Rails.root.join('tmp', 'iiif-src').tap do |src|
          FileUtils.mkdir_p(src) unless Dir.exist?(src)
        end
      end
    end
  end
end
