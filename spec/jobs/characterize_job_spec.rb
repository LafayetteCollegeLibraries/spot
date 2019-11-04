# frozen_string_literal: true
RSpec.describe CharacterizeJob do
  before do
    allow(Spot::CharacterizationService).to receive(:perform)
    allow(CreateDerivativesJob).to receive(:perform_later)

    described_class.perform_now(file_set, file_id)
  end

  let(:file_set) { instance_double(FileSet) }
  let(:file_id) { 'abc123def/files/its-a-cool-file' }

  it 'calls the Spot::CharacterizationService' do
    expect(Spot::CharacterizationService)
      .to have_received(:perform)
      .with(file_set, file_id, nil)
  end

  it 'enqueues Derivatives creation' do
    expect(CreateDerivativesJob)
      .to have_received(:perform_later)
      .with(file_set, file_id, nil)
  end
end
