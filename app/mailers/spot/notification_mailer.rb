# frozen_string_literal: true
module Spot
  class NotificationMailer < ::ApplicationMailer

    # @param [User] receiver
    def notification_email(notification, receiver)
      @comment = notification.comment

      mail(to: %("#{receiver.display_name}" <#{receiver.email}>),
           subject: notification.subject)
    end
  end
end
