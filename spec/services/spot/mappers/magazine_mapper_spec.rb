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
      before do
        @original_logger = Rails.logger

        class FakeLogger < Logger
          attr_reader :messages
          def initialize(*args)
            super(File::NULL)
            @messages = []
          end

          def add(*args)
            @messages << args
            super(*args)
          end
        end

        Rails.logger = logger
      end

      after do
        Rails.logger = @original_logger
        Object.send(:remove_const, :FakeLogger)
      end

      let(:logger) { FakeLogger.new(File::NULL)  }
      let(:metadata) { {'dc:coverage' => ['Coolsville, Daddy-O']} }

      it 'writes a warning to the logger' do
        expect(based_near_attributes).to be_empty
        expect(logger.messages).not_to be_empty
        expect(logger.messages.first.first).to eq Logger::WARN
      end
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

    let(:field) { 'TitleInfoPartNumber' }

    it_behaves_like 'a mapped field'
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

    let(:metadata) { {'TitleInfoSubtitle' => value} }
    let(:value) { ['A prestigious publication'] }

    it { is_expected.to eq value }
  end

  describe '#title' do
    subject { mapper.title }

    context 'when `TitleInfoNonSort` exists' do
      let(:value) { ['The Lafayette'] }
      let(:metadata) do
        {
          'TitleInfoNonSort' => ['The'],
          'TitleInfoTitle' => ['Lafayette'],
        }
      end

      it { is_expected.to eq value }
    end

    context 'when `TitleInfoNonSort` does not exist' do
      let(:value) { ['Lafayette'] }
      let(:metadata) do
        {
          'TitleInfoNonSort' => [],
          'TitleInfoTitle' => ['Lafayette']
        }
      end

      it { is_expected.to eq value }
    end

    context 'when `PartDate_NaturalLanguage` is present' do
      let(:value) { ['The Lafayette (November 1930)'] }
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
