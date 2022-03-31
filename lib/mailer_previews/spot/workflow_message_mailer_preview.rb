# frozen_string_literal: true
module Spot
  # Previews for workflow_mailer messages. None of the objects initialized within
  # should be persisted to the database, but there should be enough defined to be
  # able to render an accurate-ish preview.
  #
  # To view, visit localhost:3000/rails/mailers/spot/workflow_message_mailer
  # @see https://guides.rubyonrails.org/v5.2/action_mailer_basics.html#previewing-emails
  class WorkflowMessageMailerPreview < ::ActionMailer::Preview
    delegate :advisor_requests_changes,
             :changes_pending_advisor_review,
             :changes_pending_library_review,
             :submission_confirmation,
             :submission_deposited,
             :submission_pending_advisor_review,
             :submission_pending_library_review,
             to: :mailer

    private

    def mailer
      WorkflowMessageMailer.with(recipient: recipient,
                                 performing_user: performing_user,
                                 document: document,
                                 comment: comment)
    end

    # need to create these users bc the email helper looks up depositors by email address (rather than relying on the performing_user)
    def recipient
      @recipient ||= User.find_or_create_by(display_name: 'Recipient Patron', email: 'no-reply+recipient@lafayette.edu', username: 'no-reply+recipient')
    end

    def performing_user
      @performing_user ||= User.find_or_create_by(display_name: 'Action Patron', email: 'no-reply+performing@lafayette.edu', username: 'no-reply+performing')
    end

    def comment
      @comment ||= "This is a comment I have to make about this work.\n\nAnd I've made it\nwith line breaks.\n\n"
    end

    def document
      @document ||=
        StudentWork.new(id: 'test-abc123',
                        title: ['A Test Student Work'],
                        description: ['A work submitted to let me graduate (please let me graduate!)'],
                        advisor: ['dss@lafayette.edu'],
                        academic_department: ['Libraries'],
                        division: ['Humanites'],
                        resource_type: ['Project'],
                        rights_statement: ['http://rightsstatements.org/vocab/NKC/1.0/'],
                        depositor: performing_user.email)
    end
  end
end
