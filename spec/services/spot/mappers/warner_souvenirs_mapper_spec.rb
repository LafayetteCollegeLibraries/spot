# frozen_string_literal: true
RSpec.describe Spot::Mappers::WarnerSouvenirsMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper'

  describe '#date' do
    subject { mapper.date }

    let(:metadata) do
      { 'date.artifact.lower' => ['1930'], 'date.artifact.upper' => ['1952-06'] }
    end

    it { is_expected.to eq ['1930/1952-06'] }
  end

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

  describe '#description' do
    subject { mapper.description }

    let(:metadata) { { 'description.critical' => ['It is an Image. A nice one.'] } }

    it { is_expected.to eq [RDF::Literal('It is an Image. A nice one.', language: :en)] }
  end

  describe '#language' do
    subject { mapper.language }

    let(:field) { 'language' }

    it_behaves_like 'a mapped field'
  end

  describe '#location' do
    subject { mapper.location }

    let(:metadata) do
      { 'coverage.location' => ['http://www.geonames.org/1816670/'],
        'coverage.location.country' => ['https://www.geonames.org/1814991/'] }
    end

    it { is_expected.to eq [RDF::URI('http://www.geonames.org/1816670/'), RDF::URI('https://www.geonames.org/1814991/')] }
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

  describe '#rights_statement' do
    subject { mapper.rights_statement }

    let(:metadata) { { 'rights.statement' => ['http://rightsstatements.org/vocab/InC-EDU/1.0/'] } }

    it { is_expected.to eq [RDF::URI('http://rightsstatements.org/vocab/InC-EDU/1.0/')] }
  end

  describe '#subject' do
    subject { mapper.subject }

    let(:metadata) { { 'subject' => ['http://id.worldcat.org/fast/1316662'] } }

    it { is_expected.to eq [RDF::URI('http://id.worldcat.org/fast/1316662')] }
  end
end
