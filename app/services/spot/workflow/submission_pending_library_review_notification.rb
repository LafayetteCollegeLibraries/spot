# frozen_string_literal: true
module Spot
  module Workflow
    class SubmissionPendingLibraryReviewNotification < AbstractNotification
      self.mailer_method = :submission_pending_library_review

      private

      def subject
        'Submission requires review'
      end

      def message
        "A work submitted by #{depositor.display_name} has been approved by its advisor (#{user.display_name}) " \
          "and requires your review." +
          wrapped_comment_html +
          "View <em>#{link_to(document_title, document_path)}</em> to approve or request changes."
      end
    end
  end
end
