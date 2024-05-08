# frozen_string_literal: true
RSpec.describe PdfViewerHelper do
  describe '#viewer_url' do
    subject { helper.viewer_url(path) }

    before do
      # we can't mock +current_search_session+ because it's a helper method
      # defined by the CatalogController, so this is the next best thing
      allow(helper).to receive(:search).and_return search_double
    end

    let(:base) { '/pdf/web/viewer.html' }
    let(:path) { '/downloads/abc123' }
    let(:params) { {} }
    let(:search_double) { instance_double(Search, query_params: params) }

    context 'when query_param is not present' do
      it { is_expected.to eq "#{base}?file=#{path}#" }
    end

    context 'when query_param is present' do
      let(:params) { { q: 'search term' } }
      let(:encoded_q) { URI.encode_www_form_component(params[:q]) }

      it { is_expected.to eq "#{base}?file=#{path}#search=#{encoded_q}&phrase=true" }
    end

    context 'when page param is present' do
      let(:params) { { page: '5' } }

      it { is_expected.to eq "#{base}?file=#{path}#page=5" }
    end
  end
end
