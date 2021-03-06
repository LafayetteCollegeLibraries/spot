# frozen_string_literal: true
require 'date'

RSpec.describe Spot::Mappers::NewspaperMapper do
  let(:mapper) { described_class.new }
  let(:metadata) do
    {
      'dc:coverage' => ['United States, Pennsylvania, Northampton County, Easton'],
      'dc:rights' => ['https://creativecommons.org/publicdomain/mark/1.0/']
    }
  end

  before { mapper.metadata = metadata }

  describe '#location_attributes' do
    subject(:location_attributes) { mapper.location_attributes }

    let(:metadata) { { 'dc:coverage' => ['United States, Pennsylvania, Northampton County, Easton'] } }

    let(:expected_value) do
      { '0' => { 'id' => 'http://sws.geonames.org/5188140/' } }
    end

    it { is_expected.to eq expected_value }

    context 'when "Easton, PA"' do
      let(:metadata) { { 'dc:coverage' => ['Easton, PA'] } }

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

    let(:metadata) { { 'date_issued' => ['1986-02-11T00:00:00Z'] } }

    it { is_expected.to eq ['1986-02-11'] }

    context 'when no date_issued present' do
      let(:metadata) { {} }

      it { is_expected.to eq [] }
    end
  end

  describe '#date_uploaded' do
    subject(:date_uploaded) { mapper.date_uploaded }

    it { is_expected.to be_nil }

    context 'when a value is provided' do
      let(:metadata) { { 'date_uploaded' => '2019-08-14T00:00:00Z' } }

      it { is_expected.to eq '2019-08-14T00:00:00Z' }
    end
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) { { 'dc:description' => ['Some informative words'] } }
    let(:value) { [RDF::Literal('Some informative words', language: :en)] }

    it { is_expected.to eq value }

    context 'when no description is present' do
      let(:metadata) { {} }

      it { is_expected.to eq [] }
    end
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:metadata) do
      {
        'dc:identifier' => ['islandora:37462', 'http://cdm.lafayette.edu/u?/newspaper,30151'],
        'url' => ['http://digital.lafayette.edu/collections/newspaper/18700901']
      }
    end

    it { is_expected.to include 'lafayette:islandora:37462' }
    it { is_expected.to include 'url:http://cdm.lafayette.edu/u?/newspaper,30151' }
    it { is_expected.to include 'url:http://digital.lafayette.edu/collections/newspaper/18700901' }

    context 'when only dc:identifier is present' do
      let(:metadata) { { 'dc:identifier' => ['islandora:37462'] } }

      it { is_expected.to eq ['lafayette:islandora:37462'] }
    end

    context 'when only url is present' do
      let(:metadata) { { 'url' => ['http://digital.lafayette.edu/collections/newspaper/18700901'] } }

      it { is_expected.to eq ['url:http://digital.lafayette.edu/collections/newspaper/18700901'] }
    end

    context 'when no identifiers are present' do
      let(:metadata) { {} }

      it { is_expected.to eq [] }
    end
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

    let(:metadata) do
      {
        'dc:title' => ['The Lafayette'],
        'date_issued' => ['2019-08-14']
      }
    end

    let(:value) { [RDF::Literal('A modern masterpiece', language: :en)] }

    it { is_expected.to eq [RDF::Literal('The Lafayette - August 14, 2019', language: :en)] }

    # is this ideal?
    context 'when no title is present' do
      let(:metadata) { {} }

      it { is_expected.to eq [] }
    end
  end
end
