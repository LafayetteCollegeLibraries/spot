# frozen_string_literal: true
RSpec.describe Spot::Workflow::PendingLibraryReviewNotification do
  let(:approver) { create(:user) }
  let(:depositor) { create(:user) }
  let(:to_user) { create(:user) }
  let(:work) { create(:student_work, user: depositor, title: ['Test Student Work']) }
  let(:entity) { instance_double('Sipity::Entity', proxy_for: work, proxy_for_global_id: work.to_global_id.to_s) }
  let(:comment) { 'Does the library approve?' }
  let(:sipity_comment) { instance_double('Sipity::Comment', comment: comment) }
  let(:recipients) { { 'to' => [to_user] } }
  let(:message) do
    "Test Student Work (<a href=\"/concern/student_works/#{work.id}\">#{work.id}</a>) was submitted by #{depositor.user_key}. " \
    "It has been approved by its advisor and is awaiting Library approval." \
    "\n\n<blockquote>#{comment}</blockquote>"
  end

  describe '.send_notification' do
    context 'with only one recipient' do
      before do
        allow(approver)
          .to receive(:send_message)
          .with(anything, message, anything)
          .exactly(1).times.and_call_original
      end

      it 'sends a message to depositor and "to" user' do
        expect { described_class.send_notification(entity: entity, user: approver, comment: sipity_comment, recipients: recipients) }
          .to change { to_user.mailbox.inbox.count }.by(1)
      end
    end

    context 'with CC users' do
      let(:cc_user_1) { create(:user) }
      let(:cc_user_2) { create(:user) }
      let(:recipients) { { 'to' => [to_user], 'cc' => [cc_user_1, cc_user_2] } }
      let(:message) do
        "Test Student Work (<a href=\"/concern/student_works/#{work.id}\">#{work.id}</a>) was submitted by #{depositor.user_key}. " \
        "It has been approved by its advisor and is awaiting Library approval."
      end
      let(:sipity_comment) { nil }

      before do
        allow(approver)
          .to receive(:send_message)
          .with(anything, message, anything)
          .exactly(3).times.and_call_original
      end

      it 'sends a message to depositor, "to" user, and all "cc" users' do
        expect { described_class.send_notification(entity: entity, user: approver, comment: sipity_comment, recipients: recipients) }
          .to change { to_user.mailbox.inbox.count }.by(1)
          .and change { cc_user_1.mailbox.inbox.count }.by(1)
          .and change { cc_user_2.mailbox.inbox.count }.by(1)
      end
    end
  end
end
