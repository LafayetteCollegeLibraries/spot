# frozen_string_literal: true
RSpec.describe Spot::Mappers::MckelvyHouseMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'it has language-tagged titles'
  it_behaves_like 'it maps image creation note'
  it_behaves_like 'it maps original create date'

  describe '#creator' do
    subject { mapper.creator }

    let(:field) { 'creator.maker' }

    it_behaves_like 'a mapped field'
  end

  describe '#date' do
    subject { mapper.date }

    let(:field) { 'date.original.search' }

    it_behaves_like 'a mapped field'
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) do
      { 'description' => ['A house on campus.'] }
    end

    it { is_expected.to eq [RDF::Literal('A house on campus.', language: :en)] }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:metadata) do
      { 'islandora_url' => ['https://digital.lafayette.edu/path/to/the/item'] }
    end

    it { is_expected.to eq ['url:http://digital.lafayette.edu/path/to/the/item'] }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:fields) { ['keyword', 'relation.ispartof'] }

    it_behaves_like 'a mapped field'
  end

  describe '#original_item_extent' do
    subject { mapper.original_item_extent }

    let(:field) { 'description.size' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'format.medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#repository_location' do
    subject { mapper.repository_location }

    let(:field) { 'source' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    let(:field) { 'resource.type' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_statement' do
    subject { mapper.rights_statement }

    let(:metadata) do
      { 'rights.statement' => ['http://rightsstatements.org/vocab/InC-EDU/1.0/'] }
    end

    it { is_expected.to eq [RDF::URI('http://rightsstatements.org/vocab/InC-EDU/1.0/')] }
  end

  describe '#source' do
    subject { mapper.source }

    let(:field) { 'description.note' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject' do
    subject { mapper.subject }

    let(:metadata) do
      { 'subject' => ['http://id.worldcat.org/fast/1898429'] }
    end

    it { is_expected.to eq [RDF::URI('http://id.worldcat.org/fast/1898429')] }
  end
end
