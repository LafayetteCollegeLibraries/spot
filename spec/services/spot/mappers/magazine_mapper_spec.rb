# frozen_string_literal: true
RSpec.describe Spot::Mappers::MagazineMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#location_attributes' do
    subject(:location_attributes) { mapper.location_attributes }

    let(:metadata) { { 'OriginInfoPlaceTerm' => [location] } }
    let(:location) { 'Easton, PA' }
    let(:expected_value) do
      { '0' => { 'id' => 'http://sws.geonames.org/5188140/' } }
    end

    it { is_expected.to eq expected_value }

    context 'when location is not in our internal mapping' do
      let(:metadata) { { 'OriginInfoPlaceTerm' => ['Coolsville, Daddy-O'] } }

      it { is_expected.to be_empty }

      it_behaves_like 'it logs a warning'
    end
  end

  describe '#creator' do
    subject { mapper.creator }

    let(:field) { 'NamePart_DisplayForm_PersonalAuthor' }

    it_behaves_like 'a mapped field'
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    let(:value) { %w[1986-02-11 2002-02-11] }
    let(:metadata) do
      { 'PartDate_ISO8601' => ['2/11/86', '2/11/02'] }
    end

    it { is_expected.to eq value }
  end

  describe '#note' do
    subject { mapper.note }

    let(:metadata) { { 'Note' => ['some information'] } }

    it { is_expected.to eq ['some information'] }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:metadata) do
      {
        'PublicationSequence' => ['10'],
        'representative_files' => ['/path/to/the/bag/data/files/lafalummag_20190800.pdf']
      }
    end

    it { is_expected.to include 'lafayette_magazine:10' }
    it { is_expected.to include 'url:http://digital.lafayette.edu/collections/magazine/lafalummag-20190800' }
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:metadata) { { 'OriginInfoPublisher' => value } }
    let(:value) { ['Lafayette College Alumni Association'] }

    it { is_expected.to eq value }
  end

  describe '#related_resource' do
    subject { mapper.related_resource }

    let(:metadata) do
      {
        'TitleInfoPartNumber' => %w[one],
        'RelatedItemHost_1_TitleInfoTitle' => %w[two red],
        'RelatedItemHost_2_TitleInfoTitle' => %w[blue one]
      }
    end

    let(:value) { %w[one two red blue] }

    it { is_expected.to eq value }

    # our failsafe
    context 'with no defined values' do
      let(:metadata) { {} }

      it { is_expected.to eq [] }
    end
  end

  describe '#resource_type' do
    subject { mapper.resource_type }

    it { is_expected.to eq ['Periodical'] }
  end

  describe '#rights_statement' do
    subject { mapper.rights_statement }

    let(:field) { 'dc:rights' }

    it_behaves_like 'a mapped field'
  end

  describe '#source' do
    subject { mapper.source }

    let(:metadata) { { 'RelatedItemHost_1_TitleInfoTitle' => value } }
    let(:value) { ['Lafayette Magazine'] }

    it { is_expected.to eq value }
  end

  describe '#subtitle' do
    subject { mapper.subtitle }

    let(:metadata) { { 'TitleInfoSubtitle' => ['A prestigious publication'] } }
    let(:value) { [RDF::Literal('A prestigious publication', language: :en)] }

    it { is_expected.to eq value }
  end

  describe '#title' do
    subject { mapper.title }

    let(:value) { [RDF::Literal(title, language: :en)] }
    let(:title) { 'The Lafayette Alumnus, Volume 7 Issue 2, February 1937' }
    let(:metadata) do
      {
        'TitleInfoNonSort' => ['The'],
        'TitleInfoTitle' => ['Lafayette Alumnus'],
        'PartDetailTypeVolume' => ['Volume 7'],
        'PartDetailTypeIssue' => ['Issue 2'],
        'PartDate_NaturalLanguage' => ['February 1937']
      }
    end

    it { is_expected.to eq value }

    context 'when `TitleInfoNonSort` exists' do
      let(:title) { 'The Lafayette' }
      let(:metadata) do
        {
          'TitleInfoNonSort' => ['The'],
          'TitleInfoTitle' => ['Lafayette']
        }
      end

      it { is_expected.to eq value }
    end

    context 'when `TitleInfoNonSort` does not exist' do
      let(:title) { 'Lafayette' }
      let(:metadata) do
        {
          'TitleInfoNonSort' => [],
          'TitleInfoTitle' => ['Lafayette']
        }
      end

      it { is_expected.to eq value }
    end

    context 'when `PartDate_NaturalLanguage` is present' do
      let(:title) { 'The Lafayette, November 1930' }
      let(:metadata) do
        {
          'TitleInfoNonSort' => ['The'],
          'TitleInfoTitle' => ['Lafayette'],
          'PartDate_NaturalLanguage' => ['November 1930']
        }
      end

      it { is_expected.to eq value }
    end

    context 'when volume info is present' do
      let(:title) { 'The Lafayette, Volume 1a' }
      let(:metadata) do
        {
          'TitleInfoNonSort' => ['The'],
          'TitleInfoTitle' => ['Lafayette'],
          'PartDetailTypeVolume' => ['Volume 1a']
        }
      end

      it { is_expected.to eq value }
    end

    context 'when issue info is present' do
      let(:title) { 'Lafayette, Issue 2' }
      let(:metadata) do
        {
          'TitleInfoTitle' => ['Lafayette'],
          'PartDetailTypeIssue' => ['Issue 2']
        }
      end

      it { is_expected.to eq value }
    end
  end

  describe '#title_alternative' do
    subject { mapper.title_alternative }

    let(:value) { [RDF::Literal(alt_title, language: :en)] }
    let(:alt_title) { 'Supplement to The Lafayette Alumnus, Nov., 1937' }
    let(:metadata) { { 'TitleInfoPartNumber' => [alt_title] } }

    it { is_expected.to eq value }
  end
end
