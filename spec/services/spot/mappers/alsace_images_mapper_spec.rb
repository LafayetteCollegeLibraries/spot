# frozen_string_literal: true
RSpec.describe Spot::Mappers::AlsaceImagesMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'it maps Islandora URLs to identifiers'
  it_behaves_like 'it maps original create date'

  describe '#date_scope_note' do
    subject { mapper.date_scope_note }

    let(:field) { 'date.period' }

    it_behaves_like 'a mapped field'
  end

  describe '#description' do
    subject { mapper.description }

    let(:field) { 'description.critical' }

    it_behaves_like 'a mapped field'
  end

  describe '#inscription' do
    subject { mapper.inscription }

    let(:metadata) do
      {
        'description.inscription.french' => ['Partez bien bien vite vers ce midi'],
        'description.inscription.german' => ['Lebende bad.'],
        'description.text.french' => ['Les vandales pleure pas!'],
        'description.text.german' => ['Volkstracht aus Allmannweier']
      }
    end

    let(:expected_results) do
      [
        RDF::Literal('Partez bien bien vite vers ce midi', language: :fr),
        RDF::Literal('Lebende bad.', language: :de),
        RDF::Literal('Les vandales pleure pas!', language: :fr),
        RDF::Literal('Volkstracht aus Allmannweier', language: :de)
      ]
    end

    it { is_expected.to include(*expected_results) }
  end

  describe '#language' do
    subject { mapper.language }

    let(:field) { 'language' }

    it_behaves_like 'a mapped field'
  end

  describe '#location' do
    subject { mapper.location }
    let(:metadata) do
      {
        'coverage.location.image' => ['https://www.geonames.org/2991214'],
        'coverage.location.postmark' => ['France'],
        'coverage.location.producer' => ['Paris, France'],
        'coverage.location.recipient' => ['Cusset, France'],
        'coverage.location.sender' => ['https://www.geonames.org/2988507/']
      }
    end
    let(:expected_values) do
      [
        RDF::URI('https://www.geonames.org/2991214'),
        'France',
        'Paris, France',
        'Cusset, France',
        RDF::URI('https://www.geonames.org/2988507/')
      ]
    end

    it { is_expected.to eq expected_values }
  end

  describe '#physical_medium' do
    subject { mapper.physical_medium }

    let(:field) { 'physical.medium' }

    it_behaves_like 'a mapped field'
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    let(:field) { 'resource.type' }

    it_behaves_like 'a mapped field'
  end

  describe '#rights_statement' do
    subject { mapper.rights_statement }

    let(:field) { 'rights.statement' }

    it_behaves_like 'a mapped field'
  end

  describe '#subject' do
    let(:metadata) { { 'subject' => ['http://id.worldcat.org/fast/1211525'] } }

    it 'converts URI values to RDF::URI objects' do
      expect(mapper.subject.all? { |sub| sub.is_a? RDF::URI }).to be true
    end
  end

  describe '#subject_ocm' do
    subject { mapper.subject_ocm }

    let(:field) { 'subject.ocm' }

    it_behaves_like 'a mapped field'
  end

  describe '#title' do
    subject { mapper.title }

    context 'when both French and German titles are available' do
      let(:metadata) do
        { 'title.french' => ['Alsaciens et Lorraines'],
          'title.german' => ['Elsässer und Lothringer'] }
      end

      it { is_expected.to eq [RDF::Literal('Alsaciens et Lorraines', language: :fr)] }
    end

    context 'when just a German title is available' do
      let(:metadata) do
        { 'title.german' => ['Elsässer und Lothringer'],
          'title.french' => [] }
      end

      it { is_expected.to eq [RDF::Literal('Elsässer und Lothringer', language: :de)] }
    end

    context 'when no titles are available' do
      it { is_expected.to eq [RDF::Literal('[Untitled]', language: :en)] }
    end
  end

  describe '#title_alternative' do
    subject { mapper.title_alternative }

    context 'when both French and German titles are available' do
      let(:metadata) do
        { 'title.french' => ['Alsaciens et Lorraines'],
          'title.german' => ['Elsässer und Lothringer'] }
      end

      it { is_expected.to eq [RDF::Literal('Elsässer und Lothringer', language: :de)] }
    end

    context 'when just a French title is available' do
      let(:metadata) do
        { 'title.french' => ['Alsaciens et Lorraines'],
          'title.german' => [] }
      end

      it { is_expected.to eq [] }
    end

    context 'when just a German title is available' do
      let(:metadata) do
        { 'title.german' => ['Elsässer und Lothringer'],
          'title.french' => [] }
      end

      it { is_expected.to eq [] }
    end

    context 'when no titles are available' do
      it { is_expected.to eq [] }
    end
  end
end
