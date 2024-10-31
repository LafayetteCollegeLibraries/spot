# frozen_string_literal: true
require 'aws-sdk-s3'
require 'fileutils'

module Spot
  # Service to download transcript files and clean them up after attachment.
  # Calls the FileSetTranscriptAttachmentService.
  #
  # @usage
  #   Spot::TranscriptDownloadService.new(file_set: file_set, transcript_name: 'subtitle.vtt').download_transcript
  #
  class TranscriptDownloadService
    # @option [FileSet] file_set
    # @option [String] transcript_Name
    def initialize(file_set:, transcript_name:)
      @file_set = file_set
      @transcript_name = transcript_name
    end

    def download_transcript
      path = "/tmp/" + transcript_name
      s3_client.get_object(key: transcript_name, bucket: s3_source, response_target: path)
      Spot::FileSetTranscriptAttachmentService.attach(path: path, file_set: file_set)
      remove_transcript(path)
    end

    def remove_transcript(path:)
      FileUtils.rm_f(path) if File.exist?(path)
    end

    private

    # source for transcript files
    def s3_source
      ENV['AWS_BULKRAX_IMPORTS_BUCKET']
    end

    # We're using AWS credentials stored within the App/Sidekiq services for authentication,
    # so the Aws::S3::Client will pick them up ambiently.
    def s3_client
      @s3_client ||= Aws::S3::Client.new
    end
  end
end
