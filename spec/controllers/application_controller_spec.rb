# frozen_string_literal: true
RSpec.describe ApplicationController do
  describe '#default_url_options' do
    subject(:options) { described_class.new.default_url_options }

    it { is_expected.not_to include :locale }
  end

  describe '#render_bookmarks_control?' do
    subject { described_class.new.render_bookmarks_control? }

    it { is_expected.to be false }
  end
end
