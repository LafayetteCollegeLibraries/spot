# frozen_string_literal: true
RSpec.describe Spot::Mappers::MdlPrintsMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#creator' do
    subject { mapper.creator }

    let(:field) { 'creator' }

    it_behaves_like 'a mapped field'
  end

  describe '#date' do
    subject { mapper.date }

    let(:field) { 'date.original' }

    it_behaves_like 'a mapped field'
  end

  describe '#description' do
    subject { mapper.description }

    let(:metadata) { { 'description' => ['Engraving with hand-coloring'] } }

    it { is_expected.to eq [RDF::Literal('Engraving with hand-coloring', language: :en)] }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:metadata) do
      { 'islandora_url' => ['http://digital.lafayette.edu/collections/lafayetteprints/mdl-prints-0001'],
        'identifier.itemnumber' => ['I.1.a'] }
    end

    it {
      is_expected.to eq [
        Spot::Identifier.new('url', 'http://digital.lafayette.edu/collections/lafayetteprints/mdl-prints-0001').to_s,
        Spot::Identifier.new('mdl', 'I.1.a').to_s
      ]
    }
  end

  describe '#inscription' do
    subject { mapper.inscription }

    let(:field) { 'description.note' }

    it_behaves_like 'a mapped field'
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:metadata) do
      {
        'keyword' => ['Marquis de Lafayette'],
        'description.series' => ['Portraits: Before 1789'],
        'relation.IsPartOf' => ['Marquis de Lafayette Prints Collection']
      }
    end

    it { is_expected.to eq ['Marquis de Lafayette', 'Portraits: Before 1789', 'Marquis de Lafayette Prints Collection'] }
  end

  describe '#language' do
    subject { mapper.language }

    let(:field) { 'language' }

    it_behaves_like 'a mapped field'
  end

  describe '#original_item_extent' do
    subject { mapper.original_item_extent }

    let(:field) { 'format.extent' }

    it_behaves_like 'a mapped field'
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:metadata) do
      { 'description.condition' => ['tear on edge of painting'],
        'format.medium' => ['painting'] }
    end

    it { is_expected.to eq ['tear on edge of painting', 'painting'] }
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:field) { 'publisher.original' }

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

    let(:metadata) { { 'rights.statement' => ['http://creativecommons.org/publicdomain/mark/1.0/'] } }

    it { is_expected.to eq [RDF::URI('http://creativecommons.org/publicdomain/mark/1.0/')] }

    context 'when no value is present' do
      let(:metadata) { {} }

      it 'throws an error' do
        expect { mapper.rights_statement }.to raise_error(KeyError)
      end
    end
  end

  describe '#title' do
    subject { mapper.title }

    let(:metadata) { { 'title' => ['DE MARQUIS DE LA FAYETTE'] } }

    it { is_expected.to eq [RDF::Literal('DE MARQUIS DE LA FAYETTE', language: nil)] }

    context 'when no value is present' do
      let(:metadata) { {} }

      it 'throws an error' do
        expect { mapper.title }.to raise_error(KeyError)
      end
    end
  end
end
