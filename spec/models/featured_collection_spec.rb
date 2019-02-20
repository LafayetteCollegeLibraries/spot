RSpec.describe FeaturedCollection do
  describe 'validations' do
    describe ':count_within_limit' do
      subject { described_class.create(collection_id: 'abc123') }

      after { described_class.delete_all }

      context 'when within limit' do
        it { is_expected.to be_valid }
      end

      context 'when limit is reached' do
        before do
          described_class::FEATURE_LIMIT.times do |n|
            described_class.create(collection_id: "new-col-#{n}")
          end
        end

        it { is_expected.not_to be_valid }
      end
    end

    describe ':order' do
      subject { described_class.create(collection_id: 'abc123', order: order) }

      context 'when within order limit' do
        let(:order) { 1 }

        it { is_expected.to be_valid }
      end

      context 'when outside order limit' do
        let(:order) { described_class::FEATURE_LIMIT + 1 }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
