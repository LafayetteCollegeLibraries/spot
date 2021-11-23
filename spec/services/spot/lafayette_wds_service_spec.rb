# frozen_string_literal: true
RSpec.describe Spot::LafayetteWdsService do
  before do
    stub_env('LAFAYETTE_WDS_URL', wds_host)

    stub_request(:get, search_uri)
      .with(headers: { 'Accept' => 'application/json', 'apikey' => api_key })
      .to_return(body: JSON.dump(response_body), status: status_code)
  end

  let(:api_key) { 'abc123def!' }
  let(:wds_host) { 'https://webdataservices.lafayette.edu' }
  let(:response_body) { {} }
  let(:status_code) { 200 }

  describe '.instructors' do
    subject { described_class.instructors(api_key: api_key, term: term) }

    let(:search_uri) { "#{wds_host}/instructors?term=#{term}" }
    let(:term) { '202130' }

    context 'when a term is valid' do
      let(:response_body) do
        [
          { 'LNUMBER' => 'L10000000', 'LAST_NAME' => 'Lafayette', 'FIRST_NAME' => 'Mark' },
          { 'LNUMBER' => 'L20000000', 'LAST_NAME' => 'Faculty', 'FIRST_NAME' => 'Joan' }
        ]
      end

      it { is_expected.to eq response_body }
    end

    context 'when an error occurs' do
      let(:status_code) { 403 }
      let(:response_body) { { 'message' => 'Username could not be found' } }

      it 'raises a SearchError' do
        expect { described_class.instructors(api_key: api_key, term: term) }
          .to raise_error(Spot::LafayetteWdsService::SearchError, 'Username could not be found')
      end
    end
  end

  describe '.person' do
    subject { described_class.person(api_key: api_key, username: username, email: email, lnumber: lnumber) }

    let(:uri_base) { "#{wds_host}/person" }
    let(:username) { nil }
    let(:email) { nil }
    let(:lnumber) { nil }
    let(:response_body) do
      { 'LNUMBER' => 'L00000000', 'LAST_NAME' => 'Malantonio', 'FIRST_NAME' => 'Anna' }
    end

    context 'without any parameters' do
      let(:search_uri) { uri_base }
      let(:response_body) do
        [
          { 'LNUMBER' => 'L10000000', 'LAST_NAME' => 'Lafayette', 'FIRST_NAME' => 'Mark' },
          { 'LNUMBER' => 'L20000000', 'LAST_NAME' => 'Faculty', 'FIRST_NAME' => 'Joan' },
          { 'LNUMBER' => 'L30000000', 'LAST_NAME' => 'Student', 'FIRST_NAME' => 'Al Starr' }
        ]
      end

      it { is_expected.to eq response_body }
    end

    context 'when using :username to search' do
      let(:username) { 'malantoa' }
      let(:search_uri) { "#{uri_base}?username=#{username}" }

      it { is_expected.to eq response_body }
    end

    context 'when using :email to search' do
      let(:email) { 'malantoa@lafayette.edu' }
      let(:search_uri) { "#{uri_base}?email=#{email}" }

      it { is_expected.to eq response_body }
    end

    context 'when using :lnumber to search' do
      let(:lnumber) { 'L00000000' }
      let(:search_uri) { "#{uri_base}?lnumber=#{lnumber}" }

      it { is_expected.to eq response_body }
    end

    context 'when a result is not found' do
      let(:username) { 'nope' }
      let(:response_body) { false }
      let(:search_uri) { "#{uri_base}?username=#{username}" }

      it { is_expected.to be false }
    end
  end

  # @todo - these are based on assumptions from reading the documentation.
  #         we're going to need to actually test this endpoint or exclude
  #         it from the service.
  describe '.term' do
    subject { described_class.term(api_key: api_key, code: code, year: year) }

    let(:code) { nil }
    let(:year) { nil }

    context 'when using :code to search' do
      let(:search_uri) { "#{wds_host}/termInfo?term=#{code}" }
      let(:code) { '201710' }
      let(:response_body) { { "TERM_CODE" => "201710", "START_DATE" => "28-AUG-17", "END_DATE" => "18-DEC-17" } }

      it { is_expected.to eq response_body }
    end

    context 'when using :year to search' do
      let(:search_uri) { "#{wds_host}/termInfo?year=#{year}" }
      let(:year) { '2017' }
      let(:response_body) do
        [{ "TERM_CODE" => "201710", "START_DATE" => "28-AUG-17", "END_DATE" => "18-DEC-17" }]
      end

      it { is_expected.to eq response_body }
    end
  end
end
