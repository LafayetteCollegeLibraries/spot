# frozen_string_literal: true
RSpec.describe Spot::WorkflowMessageMailer do
  let(:mailer) do
    described_class.with(recipient: recipient,
                         performing_user: performing_user,
                         comment: comment,
                         document: document)
  end

  let(:performing_user) { build(:user) }
  let(:recipient) { build(:user) }
  let(:comment) { '' }
  let(:document) { build(:student_work, id: 'abc123def') }

  describe '#workflow_notification' do
    subject(:mail) { mailer.workflow_notification }

    it 'does not send' do
      expect(mail.perform_deliveries).to be false
    end
  end


    # let(:message) { 'Your input is requested to approve this item' }
    # let(:subject_val) { '[LDR] Your input is requested' } # rubocop thinks we mean the test's subject when we use :subject

    # it 'renders the headers' do
    #   expect(mail.subject).to eq subject_val
    #   expect(mail.to).to eq [user.email] # Mail::Message#to strips out name
    #   expect(mail.from).to eq ['repository@lafayette.edu']
    # end

    # it 'renders the body' do
    #   expect(mail.body).to include message
    # end
  # end
end
