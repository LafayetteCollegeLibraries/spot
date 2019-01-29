# frozen_string_literal: true
require 'date'

RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#place_attributes' do
    subject(:place_attributes) { mapper.place_attributes }

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

    context 'when the MAGIC_DATE_UPLOADED is present' do
      let(:magic_date) { described_class::MAGIC_DATE_UPLOADED }
      let(:metadata) do
        {
          'dc:date' => [
            '2019-01-08T00:00:00Z',
            magic_date
          ]
        }
      end

      it { is_expected.to eq ['2019-01-08'] }
    end
  end

  describe '#date_uploaded' do
    subject { mapper.date_uploaded }

    context "when the MAGIC_DATE_UPLOADED isn't present" do
      let(:metadata) { { 'dc:date' => ['2019-01-08T00:00:00Z'] } }

      it { is_expected.to be nil }
    end

    context 'when the MAGIC_DATE_UPLOADED is present' do
      let(:magic_date) { described_class::MAGIC_DATE_UPLOADED }
      let(:metadata) do
        {
          'dc:date' => [
            '2019-01-08T00:00:00Z',
            magic_date
          ]
        }
      end

      it { is_expected.to eq magic_date }
    end
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

    it { is_expected.to eq ['Periodical'] }
  end

  describe '#rights_statement' do
    subject(:rights_statement) { mapper.rights_statement }

    let(:metadata) { { 'dc:rights' => [uri] } }
    let(:uri) { 'https://creativecommons.org/publicdomain/mark/1.0/' }

    it { is_expected.to eq [uri] }
  end

  describe '#title' do
    subject { mapper.title }

    let(:metadata) { { 'dc:title' => ['A modern masterpiece'] } }
    let(:value) { [RDF::Literal('A modern masterpiece', language: :en)] }

    it { is_expected.to eq value }
  end
end
