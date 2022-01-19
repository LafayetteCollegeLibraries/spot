# frozen_string_literal: true
RSpec.describe Spot::Workflow::PendingAdvisorReviewNotification do
  let(:advisor) { create(:user) }
  let(:depositor) { create(:user) }
  let(:to_user) { create(:user) }
  let(:advisor_key) { advisor.lnumber }
  let(:work) { create(:student_work, user: depositor, advisor: [advisor_key], title: ['Test Student Work']) }
  let(:entity) { instance_double('Sipity::Entity', proxy_for: work, proxy_for_global_id: work.to_global_id.to_s) }
  let(:comment) { 'Is this ok?' }
  let(:sipity_comment) { instance_double('Sipity::Comment', comment: comment) }
  let(:recipients) { { 'to' => [to_user] } }
  let(:subject_line) { 'Deposit needs review' }
  let(:message) do
    "Test Student Work (<a href=\"/concern/student_works/#{work.id}\">#{work.id}</a>) was submitted by #{depositor.user_key} " \
    "and is awaiting approval.\n\n<blockquote>#{comment}</blockquote>"
  end

  before do
    stub_env('LAFAYETTE_WDS_API_KEY', 'abc123def!')

    allow(Spot::LafayetteInstructorsAuthorityService)
      .to receive(:label_for).with(lnumber: advisor.lnumber)
      .and_return('Advisor, Faculty')
  end

  describe '.send_notification' do
    context 'with only one recipient' do
      before do
        allow(advisor)
          .to receive(:send_message)
          .with(anything, message, subject_line)
          .exactly(2).times.and_call_original
      end

      it 'sends a message to depositor and "to" user' do
        expect { described_class.send_notification(entity: entity, user: advisor, comment: sipity_comment, recipients: recipients) }
          .to change { to_user.mailbox.inbox.count }.by(1)
          .and change { advisor.mailbox.inbox.count }.by(1)
      end
    end

    context 'with CC users' do
      let(:cc_user_1) { create(:user) }
      let(:cc_user_2) { create(:user) }
      let(:recipients) { { 'to' => [to_user], 'cc' => [cc_user_1, cc_user_2] } }
      let(:message) do
        "Test Student Work (<a href=\"/concern/student_works/#{work.id}\">#{work.id}</a>) was submitted by #{depositor.user_key} " \
        "and is awaiting approval."
      end

      before do
        allow(advisor)
          .to receive(:send_message)
          .with(anything, message, subject_line)
          .exactly(4).times.and_call_original
      end

      it 'sends a message to depositor, "to" user, and all "cc" users' do
        expect { described_class.send_notification(entity: entity, comment: nil, user: advisor, recipients: recipients) }
          .to change { advisor.mailbox.inbox.count }.by(1)
          .and change { to_user.mailbox.inbox.count }.by(1)
          .and change { cc_user_1.mailbox.inbox.count }.by(1)
          .and change { cc_user_2.mailbox.inbox.count }.by(1)
      end
    end

    context 'when "advisor" is an email' do
      let(:advisor_key) { advisor.email }

      before do
        allow(advisor)
          .to receive(:send_message)
          .with(anything, message, subject_line)
          .exactly(2).times.and_call_original
      end

      it 'sends a message to depositor and "to" user' do
        expect { described_class.send_notification(entity: entity, user: advisor, comment: sipity_comment, recipients: recipients) }
          .to change { to_user.mailbox.inbox.count }.by(1)
          .and change { advisor.mailbox.inbox.count }.by(1)
      end
    end
  end
end
