# frozen_string_literal: true
RSpec.describe Spot::Mappers::CpwNofukoMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  describe '#creator' do
    subject { mapper.creator }

    let(:field) { 'creator.maker' }

    it_behaves_like 'a mapped field'
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) { { 'description.critical' => ['A description of the thing.'] } }

    it { is_expected.to eq [RDF::Literal('A description of the thing.', language: :en)] }
  end

  describe '#inscription' do
    subject { mapper.inscription }

    let(:metadata) do
      {
        'description.inscription.english' => ['Hello!'],
        'description.inscription.japanese' => ['こんにちは！'],
        'description.text.english' => ['A nice thing'],
        'description.text.japanese' => ['すてきなこと']
      }
    end

    let(:expected_values) do
      [
        RDF::Literal('Hello!', language: :en),
        RDF::Literal('こんにちは！', language: :ja),
        RDF::Literal('A nice thing', language: :en),
        RDF::Literal('すてきなこと', language: :ja)
      ]
    end

    it { is_expected.to eq expected_values }
  end

  describe '#location' do
    subject { mapper.location }

    let(:metadata) do
      {
        'coverage.location' => ['https://www.geonames.org/1668341', 'https://www.geonames.org/6728591'],
        'coverage.location.country' => ['https://www.geonames.org/1668284']
      }
    end

    let(:expected_values) do
      [
        RDF::URI('https://www.geonames.org/1668341'),
        RDF::URI('https://www.geonames.org/6728591'),
        RDF::URI('https://www.geonames.org/1668284')
      ]
    end

    it { is_expected.to eq expected_values }
  end

  describe '#original_item_extent' do
    subject { mapper.original_item_extent }

    let(:field) { 'format.extant' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'format.medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'creator.company' }

    it_behaves_like 'a mapped field'
  end

  describe '#related_resource' do
    subject { mapper.related_resource }

    let(:field) { 'description.citation' }

    it_behaves_like 'a mapped field'
  end

  describe '#research_assistance' do
    subject { mapper.research_assistance }

    let(:field) { 'contributor' }

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

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
