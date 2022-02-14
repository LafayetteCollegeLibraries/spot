# frozen_string_literal: true
RSpec.describe Spot::WorkflowMessageMailer do
  describe '#workflow_notification' do
    subject(:mail) { described_class.with(message: message, recipient: user, subject: subject_val).workflow_notification }

    let(:user) { build(:user) }
    let(:message) { 'Your input is requested to approve this item' }
    let(:subject_val) { '[LDR] Your input is requested' } # rubocop thinks we mean the test's subject when we use :subject

    it 'renders the headers' do
      expect(mail.subject).to eq subject_val
      expect(mail.to).to eq [user.email] # Mail::Message#to strips out name
      expect(mail.from).to eq ['repository@lafayette.edu']
    end

    it 'renders the body' do
      expect(mail.body).to include message
    end
  end
end
