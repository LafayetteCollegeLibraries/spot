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
        msg = "#{title} (#{link_to work_id, document_path}) was submitted by #{document.depositor} and is awaiting approval."
        msg += "\n\n<blockquote>#{comment}</blockquote>" unless comment.empty?
        msg
      end

      def users_to_notify
        super.concat(advisors)
      end

      def advisors
        return [] unless document.respond_to?(:advisor)
        document.advisor.map { |advisor| User.find_by(email: advisor) }.concat
      end
    end
  end
end
