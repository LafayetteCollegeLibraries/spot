# frozen_string_literal: true
RSpec.describe Spot::Mappers::WarnerSlidesMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper', skip_fields: [:date]

  describe '#date' do
    subject { mapper.date }

    let(:field) { 'date.original' }

    it_behaves_like 'a mapped field'
  end

  describe '#inscription' do
    subject { mapper.inscription }

    let(:metadata) { { 'description.text.english' => ['Text within a photograph album'] } }

    it { is_expected.to eq [RDF::Literal('Text within a photograph album', language: :en)] }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'relation.ispartof' }

    it_behaves_like 'a mapped field'
  end

  describe '#original_item_extent' do
    subject { mapper.original_item_extent }

    let(:field) { 'format.extent' }

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
