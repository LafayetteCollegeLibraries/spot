# frozen_string_literal: true
require 'aws-sdk-s3'
require 'digest/md5'
require 'fileutils'
require 'ffprober'

module Spot
  module Derivatives
    class PremadeDerivativeService
      # sets up file_set method delegations
      attr_reader :file_set
      delegate  :audio_mime_types,
                :image_mime_types,
                :pdf_mime_types,
                :office_document_mime_types,
                :video_mime_types, to: :FileSet
      delegate  :mime_type, 
                :uri, to: :file_set
      def initialize(file_set)
        @file_set = file_set
      end

      # Downloads the derivative from s3, determines it's name, deletes it, and calls the transfer method.
      #
      # @param [String] derivative, the s3 key of a premade derivative
      # @param [Integer] index, index of premade derivative in array
      # @return [void]
      def rename_premade_derivative(derivative, index)
        file_path = "/tmp/" + derivative
        s3_client.get_object(key: derivative, bucket: s3_source, response_target: file_path)
        if video_mime_types.include?(mime_type)
          res = get_video_resolution(file_path)
          # add any other checks to the file here
          key = format('%s-%d-access-%d.mp4', file_set.id, index, res[1])
        else
          # add any other checks to the file here
          key = format('%s-%d-access.mp3', file_set.id, index)
        end
        FileUtils.rm_f(file_path) if File.exist?(file_path)
        transfer_s3_derivative(derivative, key)
      end

      # Returns the resolution of a video file.
      #
      # @param [String,Pathname] filename, the src path of the file
      # @return [Array(Integer)] pair of two numbers representing the video's width and height
      def get_video_resolution(filename)
        ffprobe = Ffprober::Parser.from_file(filename)
        [ffprobe.video_streams[0].width, ffprobe.video_streams[0].height]
      end

      private

      # destination for av derivatives
      def s3_bucket
        ENV['AWS_AV_ASSET_BUCKET']
      end

      # source for premade derivatives
      def s3_source
        ENV['AWS_BULKRAX_IMPORTS_BUCKET']
      end

      # We're using AWS credentials stored within the App/Sidekiq services for authentication,
      # so the Aws::S3::Client will pick them up ambiently.
      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      # Transfers a single derviative from the source bucket to the destination bucket, renaming
      # it. Adds all uploaded keys to the stored_derivatives metadata field
      def transfer_s3_derivative(derivative, key)
        parent = file_set.parent
        stored_derivatives = parent.stored_derivatives.to_a
        stored_derivatives.push(key)
        parent.stored_derivatives = stored_derivatives
        parent.save
        src = "/" + s3_source + "/" + derivative
        s3_client.copy_object(
          bucket: s3_bucket,
          copy_source: src,
          key: key
        )
      end
    end
  end
end