# frozen_string_literal: true
RSpec.describe MintHandleJob do
  let(:service_double) { instance_double(Spot::HandleService, mint: true) }
  let(:work) { instance_double(Publication) }

  before do
    allow(Spot::HandleService).to receive(:new).with(work).and_return(service_double)
  end

  it 'calls #mint on an instance of Spot::HandleService' do
    described_class.perform_now(work)

    expect(service_double).to have_received(:mint)
  end
end
