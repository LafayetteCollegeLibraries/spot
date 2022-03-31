# frozen_string_literal: true
module Spot
  module Workflow
    class AdvisorRequestsChangesNotification < AbstractNotification
      self.mailer_method = :advisor_requests_changes

      private

      def subject
        'Changes Required'
      end

      def message
        "A submission you recently deposited (<em>#{link_to(document_title, document_path)}</em>) has been reviewed by #{user.display_name} " \
        "and requires the following changes: " + wrapped_comment_html
      end

      def users_to_notify
        super << depositor
      end
    end
  end
end
