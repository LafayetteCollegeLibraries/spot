# frozen_string_literal: true
module Spot
  module Workflow
    # Subclassing Hyrax's abstract notification to add email notifications to the #call method.
    # The Mailboxer gem (which is responsible for sending notifications to a user's inbox within
    # the application) can be configured to send emails, but it's become apparent that messages
    # that work within the small confines of the application messaging may not be detailed enough
    # for an email (and vice-versa: an email may contain more details than necessary for a
    # notification).
    #
    # To create a custom notification, subclass this class and define the following methods:
    #   - #subject
    #     - A subject for the application inbox
    #   - #message
    #     - A message for the application inbox. Uses Hyrax's default message:
    #       "#{title} (#{link_to work_id, document_path}) was advanced in the workflow by #{user.user_key} and is awaiting approval #{comment}"
    #   - #email_message
    #     - A more detailed message to be sent via email. By default, this just calls the #message method
    #   - #email_subject
    #     - A subject for the email sent. By default this prefixes #subject with "[LDR] "
    class AbstractNotification < ::Hyrax::Workflow::AbstractNotification
      # @!attribute [rw] mailer_method
      #   redefine which mailer method is called for the email notification,
      #   allowing us to use different partials where desired
      class_attribute :mailer_method
      self.mailer_method = :workflow_notification

      # Overrides the Hyrax method to send an email with an extended message to each user to notify
      def call
        users_to_notify.uniq.each do |recipient|
          Hyrax::MessengerService.deliver(user, recipient, message, subject)
          Spot::WorkflowMessageMailer.with(recipient: recipient, subject: email_subject, message: email_message, document: document)
                                     .send(mailer_method)
                                     .deliver
        end
      end

      private

      def depositor
        User.find_by(email: document.depositor)
      end

      # Intended to be overriden with a more detailed message that uses URLs (rather than paths)
      def email_message
        message
      end

      def email_subject
        "[LDR] #{subject}"
      end
    end
  end
end
