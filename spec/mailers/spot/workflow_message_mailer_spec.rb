# frozen_string_literal: true
RSpec.describe Spot::WorkflowMessageMailer do
  let(:mailer) do
    described_class.with(comment: comment,
                         document: document,
                         performing_user: performing_user,
                         recipient: recipient)
  end
  let(:comment) { "Some comments on your piece" }
  let(:document) { build(:student_work, depositor: depositor_user.email, id: 'abc123def') }
  let(:performing_user) { build(:user) }
  let(:recipient) { build(:user) }
  let(:depositor_user) { build(:user) }

  before do
    allow(User).to receive(:find_by).with(email: depositor_user.email).and_return(depositor_user)
  end

  shared_examples 'it sets the recipient and sender' do
    it { is_expected.to have_sent_email.to(recipient.email) }
    it { is_expected.to have_sent_email.from('repository@lafayette.edu') }
  end

  describe '#no_notification' do
    subject { mailer.no_notification.deliver }

    it { is_expected.not_to have_sent_email }
  end

  describe '#advisor_requests_changes' do
    subject { mailer.advisor_requests_changes.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject '[LDR] Changes are required for a work you submitted' }
  end

  describe '#changes_pending_advisor_review' do
    subject { mailer.changes_pending_advisor_review.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject "[LDR] A submission's edits require your review" }
  end

  describe '#changes_pending_library_review' do
    subject { mailer.changes_pending_library_review.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject "[LDR] A submission's edits require your review" }
  end

  describe '#library_requests_changes' do
    subject { mailer.library_requests_changes.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject '[LDR] Changes are required for a work you submitted' }
  end

  describe '#submission_confirmation' do
    subject { mailer.submission_confirmation.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject '[LDR] Thank you for your submission to the Lafayette Digital Repository!' }
  end

  describe '#submission_deposited' do
    subject { mailer.submission_deposited.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject '[LDR] Your submission has been approved!' }
  end

  describe '#submission_pending_advisor_review' do
    subject { mailer.submission_pending_advisor_review.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject '[LDR] A submitted work requires your review' }
  end

  describe '#submission_pending_library_review' do
    subject { mailer.submission_pending_library_review.deliver }

    it_behaves_like 'it sets the recipient and sender'

    it { is_expected.to have_sent_email.with_subject '[LDR] A submitted work requires your review' }
  end
end
