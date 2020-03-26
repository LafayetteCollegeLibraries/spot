# frozen_string_literal: true
RSpec.describe Spot::Mappers::CapMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'it has language-tagged titles'

  describe '#creator' do
    subject { mapper.creator }

    let(:field) { 'creator.photographer' }

    it_behaves_like 'a mapped field'
  end

  describe '#date' do
    subject { mapper.date }

    let(:field) { 'date.range' }

    it_behaves_like 'a mapped field'
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) do
      { 'description.critical' => ['A photograph of life on campus in 1964.'] }
    end

    it { is_expected.to eq [RDF::Literal('A photograph of life on campus in 1964.', language: :en)] }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'keyword' }

    it_behaves_like 'a mapped field'
  end

  describe '#original_item_extent' do
    subject { mapper.original_item_extent }

    let(:field) { 'format.size' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'format.medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject' do
    subject { mapper.subject }

    let(:metadata) do
      { 'subject' => ['http://id.worldcat.org/fast/1898429'] }
    end

    it { is_expected.to eq [RDF::URI('http://id.worldcat.org/fast/1898429')] }
  end

  describe '#title' do

  end
end
