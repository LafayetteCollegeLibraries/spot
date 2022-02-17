# frozen_string_literal: true
module Spot
  module Workflow
    class ChangesPendingAdvisorReviewNotification < AbstractNotification
      self.mailer_method = :changes_pending_advisor_review

      private

      def subject
        'Deposit needs review'
      end

      def message
        "#{user.display_name} has made changes to <em>#{link_to(document_title, document_path)}</em>." +
          wrapped_comment_html +
        "Please review and approve or request further edits."
      end

      def users_to_notify
        super + advisors
      end
    end
  end
end
