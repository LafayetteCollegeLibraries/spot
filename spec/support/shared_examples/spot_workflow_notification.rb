# frozen_string_literal: true
#
# Usage:
#   RSpec.describe 'Spot::Workflow::SomeKindOfNotification' do
#     it_behaves_like 'a Spot::Workflow notification' do
#       # these are the _required_ variables for making the example succeed
#       # (can we fail if they're not provided?)
#       let(:subject_line) { 'You have a notification' }
#       let(:message) { 'Please respond to this workflow action.<blockquote>I need some more of this.</blockquote>' }
#       let(:recipients) { [deposit_user, advisor_user] }
#
#       # these are needed to make the required variables pass
#       let(:deposit_user) { create(:user) }
#       let(:advisor_user) { create(:user) }
#       let(:comment) { 'I need some more of this.' }
#
#       # if the workflow object needs a specific value to generate its message
#       let(:workflow_object) { create(:student_work, depositor: deposit_user, advisor: [advisor_user.email]) }
#
#       # if you just need to change the type of workflow_object, use :workflow_object_factory to define the FactoryBot type
#       let(:workflow_object_factory) { :student_work }
#     end
#   end
#
RSpec.shared_examples 'a Spot::Workflow notification' do
  # @todo can we raise if these aren't defined by the time of the example? maybe put
  #       them within the 'describe' block?
  #
  # raise "The notification's subject_line must be set with `let(:subject_line)" unless defined?(subject_line)
  # raise "The notification's message must be set with `let(:message)`" unless defined?(message)

  # overrides: redefine these in the block to skip portions of the test
  # (eg: SubmissionConfirmationNotification skips the Hyrax::MessageService invocation)
  let(:skip_hyrax_messenger_service) { false }
  let(:skip_workflow_message_mailer) { false }

  # recipients defined within the scope of the shared_example invocation.
  # we'll test that the notification is sent to each recipient included here.
  # no need to raise, because it's possible that the only recipients will be
  # pulled from the workflow configuration json
  let(:recipients) { [] }

  # define these in the event that we're overriding the hyrax_messenger_service
  # so that the test won't fail with a NameError
  let(:message) { nil }
  let(:subject_line) { nil }

  # the entity being acted upon + the work it's referencing
  let(:workflow_entity) { instance_double('Sipity::Entity', proxy_for: workflow_object, proxy_for_global_id: workflow_object.to_global_id.to_s) }
  let(:workflow_object_factory) { :student_work }
  let(:workflow_object) { create(workflow_object_factory, user: depositing_user) }
  let(:depositing_user) { create(:user, given_name: 'Depositing User') }

  # comment for the action, passed as a Sipity::Comment
  let(:workflow_sipity_comment) { instance_double('Sipity::Comment', comment: workflow_comment) }
  let(:workflow_comment) { "Make it better, please?\n\nFor starters, add an abstract." }
  let(:workflow_comment_html) { workflow_comment.gsub(/\n/, '<br>') }

  # user who performed the action
  let(:workflow_action_user) { create(:user, given_name: 'Workflow Action User') }
  let(:advisor_user) { create(:user, given_name: 'Advisor') }

  # recipients defined outside of the scope of the class (from the workflow definition json, for example)
  # @see https://github.com/samvera/hyrax/blob/v2.9.6/app/services/hyrax/workflow/notification_service.rb#L48-L55
  let(:workflow_recipients) { { 'to' => [workflow_to_user], 'cc' => [workflow_cc_user] } }
  let(:workflow_to_user) { create(:user, given_name: 'Workflow To User') }
  let(:workflow_cc_user) { create(:user, given_name: 'Workflow CC User') }
  let(:total_recipients) { workflow_recipients.values.reduce([], :concat).concat(recipients).uniq }

  let(:mock_mailer) { instance_double('Spot::WorkflowMessageMailer') }
  let(:mock_email_message) { instance_double('ActionMailer::Parameterized::MessageDelivery', deliver_later: true) }

  # test that the .mailer_method is defined and is _not_ the AbstractNotification no-op
  describe '.mailer_method' do
    it 'is not the no-op default' do
      expect(described_class.mailer_method).to be_present
      expect(described_class.mailer_method).not_to eq Spot::Workflow::AbstractNotification.mailer_method
    end

    it 'exists on the provided mailer' do
      expect(described_class.mailer_class.new).to respond_to(described_class.mailer_method)
    end
  end

  describe '.mailer_class' do
    before do
      @previous_mailer_class = described_class.mailer_class
    end

    after do
      described_class.mailer_class = @previous_mailer_class
    end

    it 'is settable' do
      expect { described_class.mailer_class = ApplicationMailer }
        .to change { described_class.mailer_class }
        .from(described_class.mailer_class)
        .to(ApplicationMailer)
    end
  end

  # what we want to accomplish here is test that our notification will send to users
  # that we define within the class. but we might want to test that it will include
  # users passed via the `recipients` hash if the class is calling `super` (we don't want
  # to accidentally exclude these users by _not_ calling super)
  #
  # maybe we can merge the `recipients` array (see example above) internally with
  # local recipients hash to ensure that all of the expected users are included.
  # (that's confusing, but i think i've got it).
  describe '.send_notification' do
    before do
      allow(Hyrax::MessengerService)
        .to receive(:deliver)
        .with(workflow_action_user, kind_of(User), message, subject_line)

      allow(Spot::WorkflowMessageMailer)
        .to receive(:with)
        .with(recipient: kind_of(User), document: workflow_object,
              performing_user: workflow_action_user, comment: workflow_sipity_comment.comment.to_s)
        .and_return(mock_mailer)

      allow(mock_mailer)
        .to receive(described_class.mailer_method)
        .and_return(mock_email_message)
    end

    it 'calls Hyrax::MessengerService and Spot::WorkflowMessageMailer for each recipient' do
      described_class.send_notification(entity: workflow_entity, comment: workflow_sipity_comment, user: workflow_action_user, recipients: workflow_recipients)

      total_recipients.each do |recipient|
        unless skip_hyrax_messenger_service
          expect(Hyrax::MessengerService)
            .to have_received(:deliver)
            .with(workflow_action_user, recipient, message, subject_line)
        end

        unless skip_workflow_message_mailer
          expect(Spot::WorkflowMessageMailer)
            .to have_received(:with)
            .with(recipient: recipient, document: workflow_object,
                  performing_user: workflow_action_user, comment: workflow_sipity_comment.comment.to_s)
        end
      end

      # finally, test that our mailer has been called for each of the total recipients
      # (workflow config 'to' and 'cc' users + additional users_to_notify defined in the shared_example)
      expect(mock_mailer)
        .to have_received(described_class.mailer_method)
        .exactly(total_recipients.count).times

      expect(mock_email_message)
        .to have_received(:deliver_later)
        .exactly(total_recipients.count).times
    end
  end
end
