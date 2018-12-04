RSpec.describe Spot::Mappers::MagazineMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#based_near_attributes' do
    subject(:based_near_attributes) { mapper.based_near_attributes }

    let(:metadata) { {'OriginInfoPlaceTerm' => [location]} }
    let(:location) { 'Easton, PA' }
    let(:expected_value) do
      { '0' => { 'id' => 'http://sws.geonames.org/5188140/' } }
    end

    it { is_expected.to eq expected_value }

    context 'when location is not in our internal mapping' do
      let(:metadata) { {'OriginInfoPlaceTerm' => ['Coolsville, Daddy-O']} }

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

  describe '#description' do
    subject { mapper.description }

    let(:metadata) { {'TitleInfoPartNumber' => ['A description']} }
    let(:value) { [RDF::Literal('A description', language: :en)] }

    it { is_expected.to eq value }
  end

  describe '#identifier' do
    subject { mapper.identifier }

    let(:metadata) { {'PublicationSequence' => ['10']} }
    let(:value) { ['lafayette_magazine:10'] }

    it { is_expected.to eq value }
  end

  describe '#publisher' do
    subject { mapper.publisher }

    let(:metadata) { {'OriginInfoPublisher' => value} }
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

    it { is_expected.to eq ['Journal'] }
  end

  describe '#source' do
    subject { mapper.source }

    let(:metadata) { {'RelatedItemHost_1_TitleInfoTitle' => value} }
    let(:value) { ['Lafayette Magazine'] }

    it { is_expected.to eq value }
  end

  describe '#subtitle' do
    subject { mapper.subtitle }

    let(:metadata) { {'TitleInfoSubtitle' => ['A prestigious publication']} }
    let(:value) { [RDF::Literal('A prestigious publication', language: :en)] }

    it { is_expected.to eq value }
  end

  describe '#title' do
    subject { mapper.title }

    context 'when `TitleInfoNonSort` exists' do
      let(:value) { [RDF::Literal('The Lafayette', language: :en)] }
      let(:metadata) do
        {
          'TitleInfoNonSort' => ['The'],
          'TitleInfoTitle' => ['Lafayette'],
        }
      end

      it { is_expected.to eq value }
    end

    context 'when `TitleInfoNonSort` does not exist' do
      let(:value) { [RDF::Literal('Lafayette', language: :en)] }
      let(:metadata) do
        {
          'TitleInfoNonSort' => [],
          'TitleInfoTitle' => ['Lafayette']
        }
      end

      it { is_expected.to eq value }
    end

    context 'when `PartDate_NaturalLanguage` is present' do
      let(:value) { [RDF::Literal('The Lafayette (November 1930)', language: :en)] }
      let(:metadata) do
        {
          'TitleInfoNonSort' => ['The'],
          'TitleInfoTitle' => ['Lafayette'],
          'PartDate_NaturalLanguage' => ['November 1930']
        }
      end

      it { is_expected.to eq value }
    end
  end
end
