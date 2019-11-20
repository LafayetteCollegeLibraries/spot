# frozen_string_literal: true
RSpec.describe ApplicationController do
  describe '#default_url_options' do
    subject(:options) { described_class.new.default_url_options }

    it { is_expected.not_to include :locale }

    context 'when ENV["URL_HOST"] is present' do
      before { stub_env('URL_HOST', 'test.host') }

      it 'provides a :host option' do
        expect(options).to include :host
        expect(options[:host]).to eq 'test.host'
      end
    end

    context 'when ENV["URL_HOST"] is not present' do
      before { stub_env('URL_HOST', '') }

      it 'does not provide a :host option' do
        expect(options).not_to include :host
      end
    end
  end
end
