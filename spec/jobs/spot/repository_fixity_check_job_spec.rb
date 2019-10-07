# frozen_string_literal: true
RSpec.describe Spot::RepositoryFixityCheckJob do
  let(:batch) { instance_double(FixityCheckBatch) }

  before do
    allow(Spot::FixityCheckService).to receive(:perform).and_return(batch)
    allow(Spot::SendFixityStatusJob).to receive(:perform_now)
  end

  it 'calls the fixity service + enqueues without async_jobs' do
    described_class.perform_now(force: false)

    expect(Spot::FixityCheckService).to have_received(:perform).with(force: false)
    expect(Spot::SendFixityStatusJob).to have_received(:perform_now).with(batch)
  end

  context 'with force: true' do
    it do
      described_class.perform_now(force: true)
      expect(Spot::FixityCheckService).to have_received(:perform).with(force: true)
    end
  end
end
