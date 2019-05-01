# frozen_string_literal: true
require 'date'

RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) do
    {
      'dc:title' => ['A modern masterpiece'],
      'dc:coverage' => ['United States, Pennsylvania, Northampton County, Easton'],
      'dc:date' => %w[2018-09-01T00:00:00Z 1986-02-11T00:00:00Z],
      'dc:description' => ['Some informative words'],
      'dc:rights' => ['https://creativecommons.org/publicdomain/mark/1.0/']
    }
  end

  before { mapper.metadata = metadata }

  describe '#location_attributes' do
    subject(:location_attributes) { mapper.location_attributes }

    let(:expected_value) do
      { '0' => { 'id' => 'http://sws.geonames.org/5188140/' } }
    end

    it { is_expected.to eq expected_value }

    context 'when location is not in our internal mapping' do
      let(:metadata) { { 'dc:coverage' => ['Coolsville, Daddy-O'] } }

      it { is_expected.to be_empty }

      it_behaves_like 'it logs a warning'
    end
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    it 'chooses the older date for date_issued' do
      expect(mapper.date_issued).to eq ['1986-02-11']
    end
  end

  describe '#date_uploaded' do
    subject(:date_uploaded) { mapper.date_uploaded }

    it 'chooses the newer date of dc:date for date_uploaded' do
      expect(date_uploaded).to eq '2018-09-01T00:00:00Z'
    end

    context 'when only one date is present' do
      let(:metadata) { { 'dc:date' => ['2019-01-08T00:00:00Z'] } }

      it { is_expected.to be nil }
    end

    context 'when there are duplicate dates' do
      let(:metadata) { { 'dc:date' => %w[2019-02-08T00:00:00Z 2019-02-08T00:00:00Z] } }

      it { is_expected.to be nil }
    end
  end

  describe '#description' do
    subject { mapper.description }

    let(:value) { [RDF::Literal('Some informative words', language: :en)] }

    it { is_expected.to eq value }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:field) { 'dc:identifier' }

    it_behaves_like 'a mapped field'
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'dc:subject' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'dc:source' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'dc:publisher' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    it { is_expected.to eq ['Periodical'] }
  end

  describe '#rights_statement' do
    subject(:rights_statement) { mapper.rights_statement }

    it { is_expected.to eq ['https://creativecommons.org/publicdomain/mark/1.0/'] }
  end

  describe '#title' do
    subject { mapper.title }

    let(:value) { [RDF::Literal('A modern masterpiece', language: :en)] }

    it { is_expected.to eq value }
  end
end
