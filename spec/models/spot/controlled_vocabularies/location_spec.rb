# frozen_string_literal: true
RSpec.describe Spot::ControlledVocabularies::Location do
  subject(:resource) { described_class.new(location_uri) }

  let(:location_id) { '4931353' }
  let(:location_uri) { "http://sws.geonames.org/#{location_id}/" }

  describe '#fetch' do
    subject { resource.fetch }

    it { is_expected.to be_a Symbol }
  end

  describe '#preferred_label' do
    subject(:preferred_label) { resource.preferred_label }

    let(:username) { Qa::Authorities::Geonames.username }
    let(:api_base) { 'http://www.geonames.org/getJSON' }
    let(:api_query) { "geonameId=#{location_id}&username=#{username}" }

    let(:api_response) do
      {
        'name' => 'Brighton',
        'adminName1' => 'Massachusetts',
        'countryName' => 'United States'
      }.to_json
    end

    before do
      stub_request(:get, "#{api_base}?#{api_query}")
        .and_return(body: api_response)
    end

    it { is_expected.to eq 'Brighton, Massachusetts, United States' }

    context 'when a label is not in the cache' do
      before do
        RdfLabel.where(uri: location_uri).delete_all
      end

      it 'makes a call to the api' do
        preferred_label

        expect(WebMock)
          .to have_requested(:get, api_base)
          .with(query: { 'geonameId' => location_id, 'username' => username })
      end
    end

    context 'when a label is in the cache' do
      let(:stored_label) { 'Brightontown USA' }

      before do
        RdfLabel.where(uri: location_uri).delete_all
        RdfLabel.create(uri: location_uri, value: stored_label)
      end

      it { is_expected.to eq stored_label }

      it 'does not call the api' do
        preferred_label

        expect(WebMock).not_to have_requested(:get, api_base)
      end
    end

    context 'when one exists but not what we want' do
      let(:existing_uri) { 'http://sws.geonames.org/0123456/' }
      let(:existing_label) { 'Mokhdān' }

      before do
        RdfLabel.delete_all
        RdfLabel.create!(uri: existing_uri, value: existing_label)
      end

      it 'adds a new label' do
        preferred_label

        expect(RdfLabel.count).to be > 1
      end
    end
  end
end
