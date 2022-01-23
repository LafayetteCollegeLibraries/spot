# frozen_string_literal: true
module Spot
  class WorkflowMessageMailer < ::ApplicationMailer
    # Mailboxer::MailDispatcher is expecting this method to be named :send_email
    # @see https://github.com/mailboxer/mailboxer/blob/3e148858879110c3258b46152b11e5bfc514dc04/lib/mailboxer/mail_dispatcher.rb#L47
    #
    # @param [Mailboxer::Message] message
    # @param [User] receiver
    def send_email(message, receiver)
      @content = message.body

      mail(to: %("#{receiver.display_name}" <#{receiver.email}>), subject: message.subject)
    end
  end
end
