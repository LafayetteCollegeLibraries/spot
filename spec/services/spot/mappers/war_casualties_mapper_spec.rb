# frozen_string_literal: true
RSpec.describe Spot::Mappers::WarCasualtiesMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  it_behaves_like 'a base EAIC mapper', skip_fields: [:date, :description, :location]

  describe '#date' do
    subject { mapper.date }

    let(:metadata) do
      {
        'date.birth.search' => ['1923-10-04'],
        'date.death.search' => ['1944-10-08']
      }
    end

    it { is_expected.to eq ['1923-10-04/1944-10-08'] }
  end

  describe '#description' do
    subject { mapper.description }

    let(:value) { 'Born October 4, 1923 in Youngstown, Ohio. Killed in action on October 8, 1944 in Briey, France.' }
    let(:metadata) { { 'description.narrative' => [value] } }

    it { is_expected.to eq [RDF::Literal(value, language: :en)] }
  end

  describe '#keyword' do
    subject { mapper.keyword }

    let(:field) { 'relation.IsPartOf' }

    it_behaves_like 'a mapped field'
  end

  describe '#location' do
    subject { mapper.location }

    let(:metadata) do
      {
        'coverage.place.birth' => ['https://www.geonames.org/5177568/'],
        'coverage.place.death' => ['https://www.geonames.org/3030071/']
      }
    end

    it { is_expected.to eq [RDF::URI('https://www.geonames.org/5177568/'), RDF::URI('https://www.geonames.org/3030071/')] }
  end

  describe '#repository_location' do
    subject { mapper.repository_location }

    let(:field) { 'publisher.digital' }

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
      {
        'rights.statement' => ['http://rightsstatements.org/vocab/InC-EDU/1.0/'],
        'rights.digital' => ['This image is posted publicly for non-profit educational use, excluding print publication.']
      }
    end

    it { is_expected.to eq [RDF::URI('http://rightsstatements.org/vocab/InC-EDU/1.0/')] }
  end

  describe '#source' do
    subject { mapper.source }

    let(:field) { 'format.analog' }

    it_behaves_like 'a mapped field'
  end

  describe '#subtitle' do
    subject { mapper.subtitle }

    context 'with branch, unit, rank, and class' do
      let(:metadata) do
        {
          'description.military.branch' => ['Army'],
          'description.military.rank' => ['Sergeant'],
          'contributor.military.unit' => ['142nd Infantry - 36th Division'],
          'description.class' => ['Class of 1934']
        }
      end

      it { is_expected.to eq ['Army Sergeant, 142nd Infantry - 36th Division', 'Class of 1934'] }
    end

    context 'with branch, rank, and class' do
      let(:metadata) do
        {
          'description.military.branch' => ['Army Air Force'],
          'description.military.rank' => ['Second Lieutenant'],
          'description.class' => ['Class of 1945']
        }
      end

      it { is_expected.to eq ['Army Air Force Second Lieutenant', 'Class of 1945'] }
    end

    # for pages w/o a person
    context 'when branch, unit, rank, or class are not provided' do
      let(:metadata) { {} }

      it { is_expected.to eq [] }
    end
  end

  describe '#title' do
    subject { mapper.title }

    let(:field) { 'title.name' }

    it_behaves_like 'a mapped field'
  end
end
