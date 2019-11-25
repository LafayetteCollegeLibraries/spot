# frozen_string_literal: true
RSpec.describe ApplicationController do
  describe '#default_url_options' do
    subject(:options) { described_class.new.default_url_options }

    it { is_expected.not_to include :locale }
  end
end
