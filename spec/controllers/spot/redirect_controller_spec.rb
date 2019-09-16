# frozen_string_literal: true
RSpec.describe Spot::RedirectController do
  routes { Rails.application.routes }

  describe '#show' do
    subject { get :show, params: { url: url } }

    context 'when a matching URL exists' do
      let(:url) { 'http://cool.example.com/path/to/item' }
      let(:obj) { build(:publication, identifier: ["url:#{url}"]) }

      before { obj.save! }

      it { is_expected.to redirect_to hyrax_publication_path(obj.id) }
    end

    context 'when a matching url does not exist' do
      let(:url) { 'http://nope.example.com/this/doesnt/exist' }

      it { is_expected.to have_http_status :not_found }
    end
  end
end
