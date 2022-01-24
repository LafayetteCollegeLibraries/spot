# frozen_string_literal: true
RSpec.describe Spot::WorkflowMessageMailer do
  describe '#send_email' do
    subject(:mail) { described_class.send_email(message, receiver) }

    let(:message) { instance_double('Mailboxer::Message', body: message_body, subject: message_subject) }
    let(:receiver) { build(:user) }
    let(:message_body) { 'Your input is requested to approve this item' }
    let(:message_subject) { '[Lafayette Digital Repository] Your input is requested' }

    it 'renders the headers' do
      expect(mail.subject).to eq message.subject
      expect(mail.to).to eq [receiver.email]
      expect(mail.from).to eq ['repository@lafayette.edu']
    end

    it 'renders the body' do
      expect(mail.body).to include message_body
    end
  end
end
