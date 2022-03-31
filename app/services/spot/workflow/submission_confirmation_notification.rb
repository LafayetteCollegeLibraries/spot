# frozen_string_literal: true
module Spot
  module Workflow
    class SubmissionConfirmationNotification < AbstractNotification
      self.mailer_method = :submission_confirmation

      # Skip the application notification in favor of just emailing a confirmation to the depositor(s).
      # Going to keep the pattern of iterating through an array of users_to_notify, rather than just
      # contacting the depositor directly, so that we have room to expand in a case of multiple authors.
      def call
        users_to_notify.uniq.each do |recipient|
          workflow_message_mailer(to: recipient).send(mailer_method).deliver_later
        end
      end

      private

      def users_to_notify
        super << depositor
      end
    end
  end
end
