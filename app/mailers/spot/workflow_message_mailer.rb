# frozen_string_literal: true
module Spot
  class WorkflowMessageMailer < ::ApplicationMailer
    # @param [Mailboxer::Message] message
    # @param [User] receiver
    def send_mailboxer_email(message, receiver)
      @content = message.body.html_safe

      mail(to: %("#{receiver.display_name}" <#{receiver.email}>), subject: message.subject)
    end
  end
end
