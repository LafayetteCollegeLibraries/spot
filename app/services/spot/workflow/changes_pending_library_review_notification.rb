# frozen_string_literal: true
module Spot
  module Workflow
    class ChangesPendingLibraryReviewNotification < AbstractNotification
      self.mailer_method = :changes_pending_library_review

      private

      def subject
        'Submission requires review'
      end

      def message
        "Changes for <em>#{link_to(document_title, document_path)}</em> have been submitted by #{user.display_name} and require your review." +
          wrapped_comment_html
      end
    end
  end
end
