# frozen_string_literal: true
RSpec.describe Spot::HomepagePresenter do
  let(:presenter) { described_class.new(recent_items, featured_collections) }
  let(:recent_items) { [] }
  let(:featured_collections) { [] }

  describe '#show_senior_honors_thesis_block?' do
    subject { presenter.show_senioor_honors_thesis_block? }

    before do
      allow(Flipflop).to receive(:enabled?).with(:show_senior_honors_thesis_block).and_return(enabled)
    end

    context 'when the feature is enabled' do
      let(:enabled) { true }

      it { is_expected.to be true }
    end

    context 'when the feature is disabled' do
      let(:enabled) { false }

      it { is_expected.to be false }
    end
  end
end
