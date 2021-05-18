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

    context 'when an https URL is passed' do
      let(:url) { 'https://digital.lafayette.edu' }
      let(:obj) { build(:publication, identifier: ['url:http://digital.lafayette.edu']) }

      before { obj.save! }

      it { is_expected.to redirect_to hyrax_publication_path(obj.id) }
    end

    context 'when a matching url does not exist' do
      let(:url) { 'http://nope.example.com/this/doesnt/exist' }

      it { is_expected.to have_http_status :not_found }
    end

    context 'when the item is a collection' do
      let(:collection_id) { 'colabc123' }
      let(:collection_solr_data) do
        {
          id: collection_id,
          has_model_ssim: ['Collection'],
          identifier_ssim: ["url:#{url}"]
        }
      end

      let(:url) { 'http://cool.website.org' }

      # collections require a lot more setup, so we'll just fake it by putting the data in solr
      before do
        ActiveFedora::SolrService.add(collection_solr_data)
        ActiveFedora::SolrService.commit
      end

      after do
        ActiveFedora::SolrService.delete_by_id(collection_id)
      end

      it { is_expected.to redirect_to hyrax_collection_path(collection_id)}
    end
  end
end
