# frozen_string_literal: true
module Spot
  module Workflow
    class ChangesRequiredNotification < AbstractNotification
      private

      def subject
        '[LDR] A work you deposited requires changes.'
      end

      def message
        msg = %(A work you deposited to the Lafayette Digital Repository, "#{link_to(title, document_path)}," requires additional changes to be accepted:)
        msg += comment_html
        msg + "Please make the requested changes via the #{link_to('edit work form', edit_document_path)}."
      end

      def users_to_notify
        super << depositor_user
      end
    end
  end
end
