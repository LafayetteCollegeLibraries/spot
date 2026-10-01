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
      class_attribute :service_file_use, default: Hyrax::FileMetadata::Use::SERVICE_FILE

      # Generates one derivative file for audio and two for video and then uploads them
      # to the S3 bucket via Valkyrie StorageAdapter.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_derivatives(filename)
        # thumbnails
        super

        if audio_mime_types.include?(mime_type)
          create_and_attach_audio_derivatives(filename)
        else
          create_and_attach_video_derivatives(filename)
        end
      end

      def cleanup_derivatives
        # thumbnails
        super

        find_service_files_from_file_set.each do |file|
          storage_adapter.delete(id: file.id)
        end
      end

      # only run service if bucket is defined and file includes audio mime types
      def valid?
        (audio_mime_types.include?(mime_type) || video_mime_types.include?(mime_type)) && Hyrax.config.use_valkyrie?
      end

      private

      def shuttle_filename(suffix)
        working_directory.join("#{file_set.id.to_s}-access#{suffix}")
      end

      # Uses Hydra to create one mp3 derivative of the original file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_audio_derivative_files(filename)
          Spot::FfmpegRunner.new.create(filename, shuttle_filename(".mp3"),
                                    { format: 'mp3' })
      end

      # Uses Hydra to create two mp4 derivatives of the original file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [void]
      def create_video_derivative_files(filename)
        Spot::FfmpegRunner.new.create(filename, shuttle_filename("-480.mp4"), 
                                  { format: 'mp4',
                                    size: get_derivative_resolution(filename, 480),                                          
                                    video: "-g 30 -b:v 2500k",
                                    audio: "-b:a 256k -ar 44100" })
        Spot::FfmpegRunner.new.create(filename, shuttle_filename("-1080.mp4"), 
                                  {format: 'mp4',
                                    size: get_derivative_resolution(filename, 1080),                                          
                                    video: "-g 30 -b:v 8000k",
                                    audio: "-b:a 256k -ar 44100" })
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

      # Use Hyrax::ValkyrieUpload service (see #upload_service) to move the shuttle
      # file(s) to S3, create a FileMetadata object for each file, and attach the
      # object(s) to the file_set as a Hyrax::FileMetadata::Use::SERVICE_FILE.
      #
      # @return Hyrax::FileMetadata
      def attach_service_file_to_file_set(shuttles)
        for file in shuttles do
          upload_service.upload(
            filename: File.basename(file),
            file_set: file_set,
            mime_type: 'image/tiff',
            io: File.open(file),
            skip_derivatives: true,
            use: service_file_use,
            user: deposit_user
          )
        end
      end

      # Manages the file creation, upload, and deletion for audio derivatives
      def create_and_attach_audio_derivatives(filename)
        return no_bucket_warning if s3_bucket.blank?

        create_audio_derivative_files(filename)
        attach_service_file_to_file_set([shuttle_filename(".mp3")]) && delete_shuttle_file!
      end

      # Manages the file creation, upload, and deletion for video derivatives
      def create_and_attach_video_derivatives(filename)
        return no_bucket_warning if s3_bucket.blank?

        create_video_derivative_files(filename)
        attach_service_file_to_file_set([shuttle_filename("-480.mp4"), shuttle_filename("-1080.mp4")]) && delete_shuttle_file!
      end

      def delete_shuttle_file!
        FileUtils.rm_f(shuttle_filename(".mp3")) if File.exist?(shuttle_filename(".mp3"))
        FileUtils.rm_f(shuttle_filename("-480.mp4")) if File.exist?(shuttle_filename("-480.mp4"))
        FileUtils.rm_f(shuttle_filename("-1080.mp4")) if File.exist?(shuttle_filename("-1080.mp4"))
      end

      def deposit_user
        User.find_or_create_system_user(Hyrax.config.system_user_key)
      end

      def find_service_files_from_file_set
        Hyrax.query_service
             .custom_queries
             .find_many_file_metadata_from_ids(ids: file_set.file_ids)
             .select { |file| file.pcdm_use.include?(service_file_use) }
      end

      def no_bucket_warning
        Rails.logger.warn('Skipping AV derivative generation because the AWS_AV_ASSET_BUCKET environment variable is not defined.')
        false
      end

      def s3_bucket
        ENV['AWS_AV_ASSET_BUCKET']
      end

      def av_storage_adapter
        Valkyrie::StorageAdapter.find(:av_source_s3)
      end

      def upload_service
        Hyrax::ValkyrieUpload.new(storage_adapter: av_storage_adapter)
      end

      def working_directory
        @working_directory ||= Rails.root.join('tmp', 'av-src').tap do |src|
          FileUtils.mkdir_p(src) unless Dir.exist?(src)
        end
      end
    end
  end
end
