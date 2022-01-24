# frozen_string_literal: true
module Spot
  # Previews for workflow_mailer messages. None of the objects initialized within
  # should be persisted to the database, but there should be enough defined to be
  # able to render an accurate-ish preview.
  #
  # To view, visit localhost:3000/rails/mailers/spot/workflow_message_mailer
  # @see https://guides.rubyonrails.org/v5.2/action_mailer_basics.html#previewing-emails
  class WorkflowMessageMailerPreview < ::ActionMailer::Preview
    # `Sipity::Entity` objects need the source to be persisted, so we'll make a Struct
    # that provides the methods used within `Hyrax::Workflow::AbstractNotification`
    MockEntity = Struct.new(:proxy_for) do
      def proxy_for_global_id
        proxy_for.to_global_id.to_s
      end
    end

    # A mock `Mailboxer::Message` object
    WrappedMessage = Struct.new(:subject, :body, :recipient)

    def changes_required
      render_email('ChangesRequiredNotification', 'Please add an abstract to the submission')
    end

    def pending_advisor_review
      render_email('PendingAdvisorReviewNotification', 'Is this change okay?')
    end

    def pending_library_review
      render_email('PendingLibraryReviewNotification', 'Looks good to me (the advisor)')
    end

    private

    def admin_set
      @admin_set ||= AdminSet.find(AdminSet.find_or_create_default_admin_set_id)
    end

    def load_klass(klass)
      Spot::Workflow.const_get(klass)
    rescue NameError
      Hyrax::Workflow.const_get(klass)
    end

    def render_email(klass, comment)
      message = wrapped_message_for(klass, comment: comment)
      WorkflowMessageMailer.send_mailboxer_email(message, message.recipient)
    end

    def receiver
      @receiver ||= User.new(id: 1002, display_name: 'Receiving Patron', email: 'no-reply@lafayette.edu', username: 'no-reply')
    end

    def sender
      @send ||= User.new(id: 1001, display_name: 'Sending Patron', email: 'no-reply@lafayette.edu', username: 'no-reply')
    end

    def sipity_entity
      MockEntity.new(work)
    end

    def work
      @work ||=
        StudentWork.new(id: 'test-abc123',
                        title: ['A Test Student Work'],
                        description: ['A work submitted to let me graduate (please let me graduate!)'],
                        advisor: ['dss@lafayette.edu'],
                        academic_department: ['Libraries'],
                        division: ['Humanites'],
                        resource_type: ['Project'],
                        rights_statement: ['http://rightsstatements.org/vocab/NKC/1.0/'])
    end

    def wrap_comment(message)
      Sipity::Comment.new(comment: message)
    end

    def wrapped_message_for(klass, comment:)
      notification = load_klass(klass).new(sipity_entity, wrap_comment(comment), sender, to: receiver)
      WrappedMessage.new(notification.send(:subject), notification.send(:message).html_safe, receiver)
    end
  end
end
