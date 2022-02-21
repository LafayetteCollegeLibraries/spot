# frozen_string_literal: true
module Spot
  module Workflow
    class LibraryRequestsChangesNotification < AbstractNotification
      self.mailer_method = :library_requests_changes

      private

      def subject
        'Submission requires changes'
      end

      # @todo helperize 'Review and Approval' title
      def message
        "Library staff have reviewed <em>#{link_to(document_title, document_path)}</em> and request the following changes:" +
          wrapped_comment_html +
          "Please make the changes and update the Review and Approval form at the top of the page."
      end
    end
  end
end
