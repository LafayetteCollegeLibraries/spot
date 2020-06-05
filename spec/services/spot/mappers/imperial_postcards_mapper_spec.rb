# frozen_string_literal: true
RSpec.describe Spot::Mappers::ImperialPostcardsMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  describe '#creator' do
    subject { mapper.creator }

    let(:field) { 'creator.maker' }

    it_behaves_like 'a mapped field'
  end

  describe '#date_scope_note' do
    subject { mapper.date_scope_note }

    let(:field) { 'description.indicia' }

    it_behaves_like 'a mapped field'
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

  describe '#keyword' do
    subject { mapper.keyword }

    let(:fields) { ['keyword', 'relation.ispartof'] }

    it_behaves_like 'a mapped field'
  end

  describe '#language' do
    subject { mapper.language }

    let(:field) { 'language' }

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

    let(:fields) { ['description.citation', 'relation.seealso'] }

    it_behaves_like 'a mapped field'
  end

  describe '#research_assistance' do
    subject { mapper.research_assistance }

    let(:field) { 'contributor' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
