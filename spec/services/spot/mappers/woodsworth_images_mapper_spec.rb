# frozen_string_literal: true
RSpec.describe Spot::Mappers::WoodsworthImagesMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  describe '#date_associated' do
    subject { mapper.date_associated }

    let(:metadata) do
      { 'date.image.lower' => ['1921-01'], 'date.image.upper' => ['1932-02-11'] }
    end

    it { is_expected.to eq ['1921-01/1932-02-11'] }
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
        'description.inscription.japanese' => ['こんにちは！']
      }
    end

    let(:expected_values) do
      [RDF::Literal('Hello!', language: :en), RDF::Literal('こんにちは！', language: :ja)]
    end

    it { is_expected.to eq expected_values }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'relation.ispartof' }

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

  describe '#resource_type' do
    subject { mapper.resource_type }

    context 'when a value is present' do
      let(:metadata) { { 'resource.type' => ['Postcard'] } }

      it { is_expected.to eq ['Postcard'] }
    end

    context 'when no value is present' do
      it { is_expected.to eq ['Image'] }
    end
  end

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end
end
