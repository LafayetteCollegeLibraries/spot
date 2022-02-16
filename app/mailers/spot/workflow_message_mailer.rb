# frozen_string_literal: true
module Spot
  class WorkflowMessageMailer < ::ApplicationMailer
    before_action :extract_params

    default to: -> { recipient_address }

    helper WorkflowMailerHelper

    def changes_required
      mail(subject: '[LDR] A submission you deposited requires changes')
    end

    def changes_pending_advisor_review
      mail(subject: "[LDR] A submission's changes require your view")
    end

    def submission_confirmation
      mail(subject: '[LDR] Thank you for your submission into the Lafayette Digital Repository!')
    end

    def submitted_pending_advisor_review
      mail(subject: '[LDR] A submitted work requires your review')
    end

    # Defined in AbstractMailer, this should be a no-op
    def no_notification
      mail.perform_deliveries = false
    end

    private

    def extract_params
      @recipient = params[:recipient]
      @performing_user = params[:performing_user]
      @document = params[:document]
      @comment = params[:comment].strip
    end

    # I don't think email_address_with_name exists in 5.2, so this is that
    def recipient_address
      return @recipient.email if @recipient.display_name.blank?

      "#{@recipient.display_name} <#{@recipient.email}>"
    end
  end
end
