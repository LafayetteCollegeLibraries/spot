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
  end
end
