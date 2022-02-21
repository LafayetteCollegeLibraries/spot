# frozen_string_literal: true
RSpec.describe Spot::Workflow::SubmissionConfirmationNotification do
  it_behaves_like 'a Spot::Workflow notification' do
    let(:skip_hyrax_messenger_service) { true }

    let(:recipients) { [depositing_user] }
  end
end
