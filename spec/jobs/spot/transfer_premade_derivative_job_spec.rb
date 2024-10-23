# frozen_string_literal: true
RSpec.describe Spot::TransferPremadeDerivativeJob do
  let(:service_double) { instance_double(Spot::Derivatives::PremadeDerivativeService) }
  let(:file_set) { instance_double(FileSet) }
  let(:derivative) { "derivative" }
  let(:index) { 0 }

  before do
    allow(Spot::Derivatives::PremadeDerivativeService).to receive(:new).with(file_set).and_return(service_double)
  end

  it 'calls #rename_premade_derivative on an instance of Spot::Derivatives::PremadeDerivativeService' do
    described_class.perform_now(file_set, derivative, index)

    expect(service_double).to have_received(:rename_premade_derivative).with("derivative", 0)
  end
end
