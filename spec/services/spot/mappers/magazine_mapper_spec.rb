RSpec.describe Spot::Mappers::MagazineMapper do
  let(:mapper) { described_class.new }
  let(:metadata) { {} }

  before { mapper.metadata = metadata }

  describe '#publisher' do
    subject { mapper.publisher }

    let(:metadata) { {'OriginInfoPublisher' => value} }
    let(:value) { ['Lafayette College Alumni Association'] }

    it { is_expected.to eq value }
  end

  describe '#date_issued' do
    subject { mapper.date_issued }

    context 'when date is before 2000' do
      let(:metadata) { {'PartDate_ISO8601' => '2/11/86'} }
      let(:value) { ['1986-02-11'] }

      it { is_expected.to eq value }
    end

    context 'when date is after 2000' do
      let(:metadata) { {'PartDate_ISO8601' => '2/11/02'} }
      let(:value) { ['2002-02-11'] }

      it { is_expected.to eq value }
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
