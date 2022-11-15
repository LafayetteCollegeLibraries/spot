# frozen_string_literal: true
RSpec.describe Spot::CharacterizationService do
  subject { described_class.run(proxy, filename) }

  let(:proxy) { instance_double(Hydra::PCDM::File) }
  let(:filename) { '/path/to/the/file' }
  let(:tool) { :fits_servlet }
  let(:service_double) { instance_double(described_class, characterize: :ran_characterize) }

  before do
    allow(described_class).to receive(:run).with(proxy, filename).and_call_original
    allow(described_class).to receive(:new).with(proxy, filename, ch12n_tool: tool).and_return(service_double)
  end

  it 'is set to be the service for CharacterizeJob' do
    expect(CharacterizeJob.characterization_service).to eq described_class
  end

  context 'when FITS_SERVLET_URL present in ENV' do
    before do
      stub_env('FITS_SERVLET_URL', 'http://localhost/fits')
    end

    it 'passes the :fits_servlet tool to the initializer' do
      described_class.run(proxy, filename)

      expect(described_class).to have_received(:new).with(proxy, filename, ch12n_tool: tool)
    end
  end

  context 'when FITS_SERVLET_URL is not present in ENV' do
    let(:tool) { :fits }

    it 'passes the :fits tool to the initializer' do
      described_class.run(proxy, filename)

      expect(described_class).to have_received(:new).with(proxy, filename, ch12n_tool: tool)
    end
  end

  context 'when a tool is passed as an option' do
    let(:tool) { :some_advanced_tool }

    before do
      allow(described_class).to receive(:run).with(proxy, filename, ch12n_tool: tool).and_call_original
    end

    it 'uses the provided tool' do
      described_class.run(proxy, filename, ch12n_tool: tool)

      expect(described_class).to have_received(:new).with(proxy, filename, ch12n_tool: tool)
    end
  end
end
