# frozen_string_literal: true
module Spot
  module Workflow
    class ChangesRequiredNotification < ::Hyrax::Workflow::AbstractNotification
      private

      def subject
        "The item you deposited requires changes."
      end

      def message
        msg = "#{title} (#{link_to(work_id, document_path)}) requires additional changes before approval."
        msg += "\n\n<blockquote>#{comment}</blockquote>" unless comment.empty?
        msg
      end

      def users_to_notify
        user_key = document.depositor
        super << ::User.find_by(email: user_key)
      end
    end
  end
end
