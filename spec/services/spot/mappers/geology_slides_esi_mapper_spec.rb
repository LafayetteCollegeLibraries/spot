# frozen_string_literal: true
RSpec.describe Spot::Mappers::GeologySlidesEsiMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'it has language-tagged titles'
  it_behaves_like 'it maps Islandora URLs to identifiers'

  describe '#date' do
    subject { mapper.date }

    let(:metadata) { { 'date.original' => ['2020-06'] } }

    it { is_expected.to eq ['2020-06'] }
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) do
      {
        'description' => ['Cycles are a fundamental rhythm of nature'],
        'description.vantagepoint' => ['vantage point: air']
      }
    end

    let(:expected_results) do
      [
        RDF::Literal('Cycles are a fundamental rhythm of nature', language: :en),
        RDF::Literal('vantage point: air', language: :en)
      ]
    end

    it { is_expected.to eq expected_results }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    context 'when a title has an ID in it' do
      let(:metadata) { { 'title' => ['[esi0001] FARMLAND IN WINTER'] } }

      it { is_expected.to include Spot::Identifier.new('geology', 'esi0001').to_s }
    end
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:fields) { ['keyword', 'relation.ispartof'] }

    it_behaves_like 'a mapped field'
  end

  describe '#location' do
    subject { mapper.location }

    let(:metadata) { { 'location' => ['https://www.geonames.org/5306040/'] } }

    it { is_expected.to eq [RDF::URI('https://www.geonames.org/5306040/')] }
  end

  describe '#related_resource' do
    subject { mapper.related_resource }

    let(:fields) { ['relation.seealso.book', 'relation.seealso.image'] }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    let(:field) { 'resource.type' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_statement' do
    subject { mapper.rights_statement }

    let(:metadata) { { 'rights.statement' => ['http://rightsstatements.org/vocab/InC-EDU/1.0/'] } }

    it { is_expected.to eq [RDF::URI('http://rightsstatements.org/vocab/InC-EDU/1.0/')] }
  end

  describe '#subject' do
    subject { mapper.subject }

    let(:metadata) { { 'subject' => ['http://id.worldcat.org/fast/1142133'] } }

    it { is_expected.to eq [RDF::URI('http://id.worldcat.org/fast/1142133')] }
  end

  describe '#subtitle' do
    subject { mapper.subtitle }

    let(:metadata) { { 'coverage.location' => ['La Jolla, California. Early morning.'] } }

    it { is_expected.to eq [RDF::Literal('La Jolla, California. Early morning.', language: :en)] }
  end
end
