# frozen_string_literal: true
RSpec.describe Spot::RemoteCharacterizationService do
  subject(:service) { described_class.run(file_set, file_path) }

  before do
    stub_env('FITS_SERVLET_URL', 'http://fits.server/fits/examine')

    allow(Faraday::UploadIO)
      .to receive(:new)
      .with(file_path, 'application/octet/stream')
      .and_return(:payload)

    stub_request(:post, "http://fits.server/fits/examine")
      .with(body: { 'datafile' => 'payload' })
      .to_return(body: fits_response)
  end

  let(:file_path) { '/path/to/file' }
  let(:file) { instance_double(Hydra::PCDM::File, id: 'file-abc123') }
  let(:file_set) { instance_double(FileSet, id: 'fs-abc123', files: [file]) }
  let(:fits_response) { File.read(Rails.root.join('spec', 'fixtures', 'fits-response-jpeg.xml')) }
  let(:results) do
    { well_formed: ["true"], valid: ["true"], width: ["731"], height: ["731"] }
  end

  context 'when the servlet host is provided' do
    it { is_expected.to eq results }
  end

  context 'when the servlet host is not provided' do
    before { stub_env('FITS_SERVLET_URL', nil) }

    it 'raises an error' do
      expect { service }.to raise_error(StandardError, 'No FITS_SERVLET_URL provided!')
    end
  end
end
