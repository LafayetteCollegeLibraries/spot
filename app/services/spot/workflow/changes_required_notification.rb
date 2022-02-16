# frozen_string_literal: true
module Spot
  module Workflow
    class ChangesRequiredNotification < AbstractNotification
      self.mailer_method = :changes_required

      private

      def subject
        'A work you deposited requires changes.'
      end

      def message
        "#{link_to(title, document_path)} requires additional changes before approval:" + comment_html
      end

      def users_to_notify
        super << depositor
      end
    end
  end
end
