# frozen_string_literal: true
module Spot
  module Workflow
    # Subclassing Hyrax's abstract notification to add email notifications to the #call method.
    # The Mailboxer gem (which is responsible for sending notifications to a user's inbox within
    # the application) can be configured to send emails, but it's become apparent that messages
    # that work within the small confines of the application messaging may not be detailed enough
    # for an email (and vice-versa: an email may contain more details than necessary for a notification).
    #
    #
    class AbstractNotification < ::Hyrax::Workflow::AbstractNotification
      # @!attribute [rw] mailer_method
      #   redefine which mailer method is called for the email notification,
      #   allowing us to use different partials where desired
      class_attribute :mailer_method
      self.mailer_method = :no_notification

      # Overrides the Hyrax method to send an email with an extended message to each user to notify
      def call
        users_to_notify.uniq.each do |recipient|
          Hyrax::MessengerService.deliver(user, recipient, message.html_safe, subject)

          mailer = workflow_message_mailer(to: recipient)
          mailer.send(mailer_method).deliver_later if mailer.respond_to?(mailer_method)
        end
      end

      private

      def advisors
        return [] unless document.respond_to?(:advisor)
        document.advisor.map { |email| User.find_by(email: email) }.compact
      end

      def comment_html
        return '' if comment.strip.empty?
        comment.strip.gsub(/\n/, '<br>')
      end

      def depositor
        User.find_by(email: document.depositor)
      end

      def document_model_route_key
        document.model_name.singular_route_key
      end

      def document_title
        document.title.first
      end

      def workflow_message_mailer(to:)
        Spot::WorkflowMessageMailer.with(recipient: to,
                                         document: document,
                                         performing_user: user,
                                         comment: comment)
      end

      def wrapped_comment_html
        return '' if comment.strip.empty?

        "<blockquote>#{comment_html}</blockquote>"
      end
    end
  end
end
