# frozen_string_literal: true
RSpec.describe Spot::Mappers::WarnerNegsMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper', skip_fields: [:description]

  describe '#description' do
    subject { mapper.description }

    let(:metadata) do
      {
        'description.critical' => ["It's a postcard"],
        'description.text.english' => ['A description of the item']
      }
    end

    let(:expected_values) do
      [
        RDF::Literal("It's a postcard", language: :en),
        RDF::Literal('A description of the item', language: :en)
      ]
    end

    it { is_expected.to eq expected_values }
  end

  describe '#inscription' do
    subject { mapper.inscription }

    let(:metadata) do
      {
        'description.inscription.english' => ['Hello!'],
        'description.text.english' => ['A nice thing'],
        'description.text.japanese' => ["Hey this isn't Japanese!"]
      }
    end

    let(:expected_values) do
      [
        RDF::Literal('Hello!', language: :en),
        RDF::Literal('A nice thing', language: :en),
        RDF::Literal("Hey this isn't Japanese!", language: :en)
      ]
    end

    it { is_expected.to eq expected_values }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:fields) { ['keyword', 'relation.ispartof'] }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'format.medium' }

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

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
