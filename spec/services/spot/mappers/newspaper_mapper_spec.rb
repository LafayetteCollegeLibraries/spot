# frozen_string_literal: true
RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#based_near_attributes' do
    subject(:based_near_attributes) { mapper.based_near_attributes }

    let(:expected_value) do
      { '0' => { 'id' => 'http://sws.geonames.org/5188140/' } }
    end

    context 'when location is Easton' do
      let(:metadata) do
        {
          'dc:coverage' => ['United States, Pennsylvania, Northampton County, Easton']
        }
      end

      it { is_expected.to eq expected_value }
    end

    context 'when location is not in our internal mapping' do
      let(:metadata) { { 'dc:coverage' => ['Coolsville, Daddy-O'] } }

      it { is_expected.to be_empty }

      it_behaves_like 'it logs a warning'
    end
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    let(:value) do
      %w[
        2018-09-01
        2018-09-02
      ]
    end

    let(:metadata) do
      {
        'dc:date' => %w[
          2018-09-01T00:00:00Z
          2018-09-02T00:00:00Z
        ]
      }
    end

    it { is_expected.to eq value }
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) { { 'dc:description' => ['Some informative words'] } }
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

    let(:field) { 'dc:type' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_statement' do
    subject(:rights_statement) { mapper.rights_statement.first }

    let(:metadata) { { 'dc:rights' => [rights] } }
    let(:uri) { 'https://creativecommons.org/publicdomain/mark/1.0/' }

    context 'when in the Public domain' do
      let(:rights) { 'Public domain' }

      it { is_expected.to eq uri }
    end

    context 'when not in the Public domain' do
      let(:rights) { 'No way you can use this' }

      it { is_expected.to eq rights }
    end
  end

  describe '#title' do
    subject { mapper.title }

    let(:metadata) { { 'dc:title' => ['A modern masterpiece'] } }
    let(:value) { [RDF::Literal('A modern masterpiece', language: :en)] }

    it { is_expected.to eq value }
  end
end
