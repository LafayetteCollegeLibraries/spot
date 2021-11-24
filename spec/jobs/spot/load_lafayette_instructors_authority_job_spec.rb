# frozen_string_literal: true
RSpec.describe Spot::LoadLafayetteInstructorsAuthorityJob do
  before do
    allow(Spot::LafayetteInstructorsAuthorityService).to receive(:load).with(term: '202110')
  end

  it 'calls the LafayetteInstructorsAuthorityService' do
    described_class.perform_now

    expect(Spot::LafayetteInstructorsAuthorityService).to have_received(:load).with(term: '202110').exactly(1).time
  end
end
