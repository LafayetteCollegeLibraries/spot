# frozen_string_literal: true
RSpec.describe Spot::RightsStatementService do
  let(:service) { described_class.new }

  describe '#shortcode' do
    subject(:shortcode) { service.shortcode(uri) { fallback } }

    let(:fallback) { 'none' }

    context 'when a shortcode exists' do
      let(:uri) { 'http://creativecommons.org/licenses/by-nc-sa/4.0/' }

      it { is_expected.to eq 'BY-NC-SA' }
    end

    context 'when a shortcode does not exist' do
      let(:uri) { 'http://no-dont-use-this.com' }

      it { is_expected.to eq fallback }
    end
  end

  describe 'all values have a shortcode' do
    it do
      expect(service.select_all_options.map(&:last).all? { |rs| service.shortcode(rs) }).to be true
    end
  end
end
