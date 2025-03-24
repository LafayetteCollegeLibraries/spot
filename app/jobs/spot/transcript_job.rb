# frozen_string_literal: true
module Spot
  # Tiny job wrapper that calls our TranscriptDownloadService
  # to do the heavy-lifting.
  class TranscriptJob < ApplicationJob
    # @option [FileSet] file_set
    # @option [String] transcript_Name
    def perform(file_set:, transcript_name:)
      Spot::TranscriptDownloadService.new(file_set: file_set, transcript_name: transcript_name).download_transcript
    end
  end
end
