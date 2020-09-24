# frozen_string_literal: true
RSpec.describe Spot::HandleService do
  subject(:service) { described_class.new(work) }

  let(:work) { instance_double(Publication, id: 'abc123def', identifier: identifiers) }
  let(:identifiers) { [] }
  let(:handle_server_url) { 'http://handle-service:8000' }
  let(:handle_prefix) { '10385' }
  let(:cert_path) { '/path/to/client/cert' }
  let(:key_path) { '/path/to/client/key' }

  describe '.env_values_defined?' do
    subject { described_class.env_values_defined? }

    context 'when all values are provided' do
      before do
        stub_env('HANDLE_SERVER_URL', handle_server_url)
        stub_env('HANDLE_PREFIX', handle_prefix)
        stub_env('HANDLE_CLIENT_CERT', cert_path)
        stub_env('HANDLE_CLIENT_KEY', key_path)
      end

      it { is_expected.to be true }
    end

    context 'when not all values are provided' do
      it { is_expected.to be false }
    end
  end

  describe '#mint' do
    subject { service.mint }

    let(:cert_double) { instance_double(OpenSSL::X509::Certificate) }
    let(:key_double) { instance_double(OpenSSL::PKey::PKey) }
    let(:body_content) { { responseCode: 1, handle: "#{handle_prefix}/#{work.id}" } }
    let(:handle_value) { "#{handle_prefix}/#{work.id}" }
    let(:request_object) do
      {
        index: 100,
        type: 'URL',
        permissions: '1110',
        data: {
          format: 'string',
          value: "http://localhost:3000/handle/#{handle_value}"
        }
      }
    end

    before do
      stub_env('HANDLE_SERVER_URL', handle_server_url)
      stub_env('HANDLE_PREFIX', handle_prefix)
      stub_env('HANDLE_CLIENT_CERT', cert_path)
      stub_env('HANDLE_CLIENT_KEY', key_path)

      allow(service).to receive(:cert_exist?).and_return(true)
      allow(service).to receive(:cert_contents).and_return(:cert_data)
      allow(service).to receive(:key_exist?).and_return(true)
      allow(service).to receive(:key_contents).and_return(:key_data)

      allow(OpenSSL::X509::Certificate).to receive(:new).with(:cert_data).and_return(cert_double)
      allow(OpenSSL::PKey).to receive(:read).with(:key_data).and_return(key_double)

      allow(work).to receive(:identifier=)
      allow(work).to receive(:save!)

      stub_request(:put, "#{handle_server_url}/api/handles/#{handle_value}")
        .with(body: JSON.dump(request_object), headers: { 'Content-Type': 'application/json' })
        .to_return(body: JSON.dump(body_content))
    end

    # testing the return value
    it { is_expected.not_to be nil }
    it { is_expected.to eq handle_value }

    it 'saves the identifier to the record' do
      service.mint

      expect(work).to have_received(:identifier=).with(["hdl:#{handle_value}"])
      expect(work).to have_received(:save!)
    end

    context 'when a responseCode != 1 is returned' do
      let(:body_content) { { responseCode: 202, handle: "#{handle_prefix}/#{work.id}" } }

      it 'throws an error' do
        expect { service.mint }
          .to raise_error(StandardError, 'Received error code minting handle [10385/abc123def]: 202')
      end
    end
  end
end
