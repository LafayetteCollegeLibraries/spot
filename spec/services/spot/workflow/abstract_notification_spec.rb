# frozen_string_literal: true
#
# @todo do we need this spec now?
RSpec.describe Spot::Workflow::AbstractNotification do
  include_context 'workflow notifications'

  let(:notification_subclass) do
    Class.new(described_class) do
      def message
        'Hi this is a notification message'
      end

      def subject
        'A notification about a workflow action'
      end
    end
  end

  describe '.send_notification' do
    let(:to_user) { create(:user) }

    context 'when one recipient' do
      let(:workflow_recipients) { { 'to' => [to_user] } }

      it 'calls Hyrax::MessengerService and Spot::WorkflowMessageMailer once' do
        notification_subclass.send_notification(entity: workflow_entity,
                                                comment: workflow_sipity_comment,
                                                user: workflow_user,
                                                recipients: workflow_recipients)

        expect(Hyrax::MessengerService)
          .to have_received(:deliver)
          .with(workflow_user, to_user, 'Hi this is a notification message', 'A notification about a workflow action')
          .exactly(1).time

        expect(Spot::WorkflowMessageMailer)
          .to have_received(:with)
          .with(recipient: to_user,
                document: workflow_object,
                performing_user: workflow_user,
                comment: workflow_comment)
          .exactly(1).time

        expect(email_message).to have_received(:deliver_later).exactly(1).time
      end
    end

    context 'with multiple recipients' do
      let(:workflow_recipients) { { 'to' => [to_user], 'cc' => [cc_user_1, cc_user_2] } }
      let(:cc_user_1) { create(:user) }
      let(:cc_user_2) { create(:user) }

      it 'calls Hyrax::MessengerService and Spot::WorkflowMessageMailer for each recipient' do
        notification_subclass.send_notification(entity: workflow_entity,
                                                  comment: workflow_sipity_comment,
                                                  user: workflow_user,
                                                  recipients: workflow_recipients)

        expect(Hyrax::MessengerService)
          .to have_received(:deliver)
          .with(workflow_user, kind_of(User), 'Hi this is a notification message', 'A notification about a workflow action')
          .exactly(3).times

        expect(Spot::WorkflowMessageMailer)
          .to have_received(:with)
          .with(recipient: kind_of(User),
                document: workflow_object,
                performing_user: workflow_user,
                comment: workflow_comment)
          .exactly(3).times

        expect(email_message).to have_received(:deliver_later).exactly(3).times
      end
    end
  end
end
