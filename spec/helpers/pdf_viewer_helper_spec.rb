# frozen_string_literal: true
RSpec.describe PdfViewerHelper do
  describe '#viewer_url' do
    subject { helper.viewer_url(path) }

    before do
      # we can't mock +current_search_session+ because it's a helper method
      # defined by the CatalogController, so this is the next best thing
      allow(helper).to receive(:search).and_return search_double
    end

    let(:base) { '/web/viewer.html' }
    let(:path) { '/downloads/abc123' }
    let(:params) { {} }
    let(:search_double) { instance_double(Search, query_params: params) }

    context 'when query_param is not present' do
      it { is_expected.to eq "#{base}?file=#{path}#" }
    end

    context 'when query_param is present' do
      let(:params) { { q: 'search term' } }

      it { is_expected.to eq "#{base}?file=#{path}#search=#{params[:q]}&phrase=true" }
    end
  end
end
