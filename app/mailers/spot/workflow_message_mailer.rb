# frozen_string_literal: true
module Spot
  class WorkflowMessageMailer < ::ApplicationMailer
    def workflow_notification
      @content = params[:message]

      mail(to: recipient, subject: subject)
    end

    private

    def recipient
      user = params[:recipient]
      return user.email unless user.display_name

      %("#{user.display_name}" <#{user.email}>)
    end

    def subject
      params[:subject]
    end
  end
end
