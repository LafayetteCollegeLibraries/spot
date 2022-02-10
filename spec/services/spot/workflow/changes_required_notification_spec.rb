# frozen_string_literal: true
RSpec.describe Spot::Workflow::ChangesRequiredNotification do
  let(:approver) { create(:user) }
  let(:depositor) { create(:user) }
  let(:to_user) { create(:user) }
  let(:work) { create(:student_work, user: depositor, title: ['Test Student Work']) }
  let(:entity) { instance_double('Sipity::Entity', proxy_for: work, proxy_for_global_id: work.to_global_id.to_s) }
  let(:comment) { "Make it better, please?\n\nTo start, add a clearer abstract." }
  let(:sipity_comment) { instance_double('Sipity::Comment', comment: comment) }
  let(:recipients) { { 'to' => [to_user] } }
  let(:subject_line) { '[LDR] A work you deposited requires changes.' }
  let(:message) do
    %(A work you deposited to the Lafayette Digital Repository, "<a href="/concern/student_works/#{work.id}">#{work.title.first}</a>," requires additional changes to be accepted:) +
      %(\n\n<blockquote>#{comment.gsub(/\n/, '<br>')}</blockquote>\n\n) +
      %(Please make the requested changes via the <a href="/concern/student_works/#{work.id}/edit">edit work form</a>.)
  end

  describe '.send_notification' do
    context 'with only one recipient' do
      before do
        allow(approver)
          .to receive(:send_message)
          .with(anything, message, subject_line)
          .exactly(2).times.and_call_original
      end

      it 'sends a message to depositor and "to" user' do
        expect { described_class.send_notification(entity: entity, user: approver, comment: sipity_comment, recipients: recipients) }
          .to change { depositor.mailbox.inbox.count }.by(1)
          .and change { to_user.mailbox.inbox.count }.by(1)
      end
    end

    context 'with CC users' do
      let(:cc_user_1) { create(:user) }
      let(:cc_user_2) { create(:user) }
      let(:recipients) { { 'to' => [to_user], 'cc' => [cc_user_1, cc_user_2] } }

      before do
        allow(approver)
          .to receive(:send_message)
          .with(anything, message, subject_line)
          .exactly(4).times.and_call_original
      end

      it 'sends a message to depositor, "to" user, and all "cc" users' do
        expect { described_class.send_notification(entity: entity, user: approver, comment: sipity_comment, recipients: recipients) }
          .to change { depositor.mailbox.inbox.count }.by(1)
          .and change { to_user.mailbox.inbox.count }.by(1)
          .and change { cc_user_1.mailbox.inbox.count }.by(1)
          .and change { cc_user_2.mailbox.inbox.count }.by(1)
      end
    end
  end
end
