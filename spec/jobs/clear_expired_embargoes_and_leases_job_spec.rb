# frozen_string_literal: true
RSpec.describe ClearExpiredEmbargoesAndLeasesJob do
  before do
    allow(Spot::EmbargoLeaseService).to receive(:clear_all_expired).with(regenerate_thumbnails: true)
  end

  it 'defers to the Spot::EmbargoLeaseService' do
    described_class.perform_now

    expect(Spot::EmbargoLeaseService).to have_received(:clear_all_expired).with(regenerate_thumbnails: true).exactly(1).times
  end
end
