# frozen_string_literal: true
module Spot
  # Tiny job wrapper that calls our TranscriptAttachmentService
  # to do the heavy-lifting.
  class TranscriptAttachmentJob < ApplicationJob
    # @option [FileSet] file_set
    def perform(file_set_id:)
      Spot::TranscriptAttachmentService.new(file_set_id: file_set_id).attach_transcripts
    end
  end
end
