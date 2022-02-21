# frozen_string_literal: true
module Spot
  # Mailer used for dispatching notifications to users as part of Workflow actions.
  # The methods defined here correspond to subclasses of Spot::Workflow::AbstractNotification
  # that define a :mailer_method class attribute.
  #
  # @see {Spot::Workflow::AbstractNotification}
  class WorkflowMessageMailer < ::ApplicationMailer
    before_action :extract_params

    default to: -> { @recipient.email }

    helper WorkflowMailerHelper

    # Defined in AbstractMailer, this should be a no-op
    def no_notification; end

    def advisor_requests_changes
      mail(subject: '[LDR] Changes are required for a work you submitted')
    end

    def changes_pending_advisor_review
      mail(subject: "[LDR] A submission's edits require your review")
    end

    def changes_pending_library_review
      mail(subject: "[LDR] A submission's edits require your review")
    end

    def library_requests_changes
      mail(subject: '[LDR] Changes are required for a work you submitted')
    end

    def submission_confirmation
      mail(subject: '[LDR] Thank you for your submission to the Lafayette Digital Repository!')
    end

    def submission_deposited
      mail(subject: '[LDR] Your submission has been approved!')
    end

    def submission_pending_advisor_review
      mail(subject: '[LDR] A submitted work requires your review')
    end

    def submission_pending_library_review
      mail(subject: '[LDR] A submitted work requires your review')
    end

    private

    def extract_params
      @comment = params[:comment].strip
      @document = params[:document]
      @performing_user = params[:performing_user]
      @recipient = params[:recipient]
    end
  end
end
