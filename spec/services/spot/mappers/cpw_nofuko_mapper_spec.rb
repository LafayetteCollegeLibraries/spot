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

    let(:metadata) do
      { 'keyword' => ['East Asia Image Collection'], 'relation.ispartof' => ['cpw-nofuko'] }
    end

    it { is_expected.to eq ['East Asia Image Collection', 'cpw-nofuko'] }
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

    let(:metadata) { { 'description.citation' => ['a good book, 2019'], 'relation.seealso' => ['[ww0001]'] } }

    it { is_expected.to eq ['a good book, 2019', '[ww0001]'] }
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

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
