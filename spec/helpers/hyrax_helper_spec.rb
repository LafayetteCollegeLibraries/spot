# frozen_string_literal: true
RSpec.describe HyraxHelper do
  describe '#available_translations' do
    subject { helper.available_translations }

    let(:sample_translations) { { 'en' => 'English' } }

    it { is_expected.to eq sample_translations }
  end
end
