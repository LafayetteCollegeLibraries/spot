# frozen_string_literal: true
require 'json'

RSpec.describe Spot::Importers::Unpaywall::Parser do
  subject(:parser) { described_class.new(doi: doi, mapper: mapper) }

  before do
    stub_request(:get, "#{api_base}/v2/#{doi}?email=#{email}")
      .and_return(body: JSON.dump(ok_payload), status: 200)
    stub_request(:get, "#{api_base}/v2/#{bad_doi}?email=#{email}")
      .and_return(body: JSON.dump(not_found_payload), status: 404)

    allow(Darlingtonia::InputRecord)
      .to receive(:from)
      .with(metadata: ok_payload, mapper: mapper)
      .and_return(input_record)
  end

  let(:api_base) { described_class::API_BASE_URL }
  let(:bad_doi) { '00.000/not-here' }
  let(:doi) { '00.000/a-good-doi' }
  let(:email) { described_class.unpaywall_email }
  let(:input_record) { instance_double(Darlingtonia::InputRecord) }
  let(:mapper) { instance_double(Spot::Mappers::UnpaywallMapper) }
  let(:not_found_payload) do
    {
      'HTTP_status_code' => 404,
      'error' => true,
      'message' => "'#{bad_doi}' is an invalid doi. See http://doi.org/#{bad_doi}"
    }
  end
  let(:ok_payload) do
    { 'title' => 'ok cool' }
  end

  describe '#records' do
    subject(:records) { parser.records }

    it { is_expected.to be_an Array }

    it 'returns an array with a single InputRecord object' do
      expect(records.first).to eq input_record
    end

    context 'when an invalid doi is returned' do
      let(:doi) { bad_doi }

      it 'raises a DOINotFound error' do
        expect { parser.records }
          .to raise_error(Spot::Importers::Unpaywall::DOINotFound, not_found_payload['message'])
      end
    end
  end
end
