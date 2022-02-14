# frozen_string_literal: true
module Spot
  module Workflow
    class PendingLibraryReviewNotification < AbstractNotification
      private

      def subject
        'Deposit needs review'
      end

      def message
        msg = "#{title} (#{link_to work_id, document_path}) was submitted by #{document.depositor}. " \
              "It has been approved by its advisor and is awaiting Library approval."
        msg += "\n\n<blockquote>#{comment}</blockquote>" unless comment.empty?
        msg
      end
    end
  end
end
