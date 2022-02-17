# frozen_string_literal: true
module Spot
  module Workflow
    # Notification sent out to a work's advisor after its initial submission
    # (differs from ChangesPendingAdvisorReview, which is intended for a
    # work-in-process context)
    class SubmissionPendingAdvisorReviewNotification < AbstractNotification
      self.mailer_method = :submitted_pending_advisor_review

      private

      def subject
        'Submission requires review'
      end

      def message
        "A work by #{depositor.display_name} (<em>#{link_to(document_title, document_path)}</em>) was submitted " \
          "and is awaiting your approval. " +
          wrapped_comment_html +
          "Please approve or request changes using the form on the work's page."
      end

      def users_to_notify
        super + advisors
      end
    end
  end
end
