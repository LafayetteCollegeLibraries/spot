# frozen_string_literal: true
module Spot
  module Workflow
    class SubmissionDepositedNotification < AbstractNotification
      self.mailer_method :submission_deposited

      private

      def subject
        'Submission approved'
      end

      def message
        "Your submission, <em>#{link_to(document_title, document_path)}</em>, has been approved! Thank you!"
      end
    end
  end
end
