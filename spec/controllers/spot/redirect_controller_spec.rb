# frozen_string_literal: true
RSpec.describe Spot::RedirectController do
  routes { Rails.application.routes }

  describe '#show' do
    subject { get :show, params: { url: url } }

    let(:solr_service) { ActiveFedora::SolrService }

    before do
      solr_service.add(solr_data)
      solr_service.commit
    end

    after do
      solr_service.delete(id: solr_data[:id])
      solr_service.commit
    end

    context 'when a matching URL exists' do
      let(:url) { 'http://cool.example.com/path/to/item' }
      let(:solr_data) do
        {
          id: 'matching-test',
          has_model_ssim: ['Publication'],
          identifier_ssim: ["url:#{url}"]
        }
      end

      it { is_expected.to redirect_to hyrax_publication_path(solr_data[:id]) }
    end

    context 'when an https URL is passed' do
      let(:url) { 'https://digital.lafayette.edu' }
      let(:solr_data) do
        {
          id: 'https-test',
          has_model_ssim: ['Image'],
          identifier_ssim: ['url:http://digital.lafayette.edu']
        }
      end

      it { is_expected.to redirect_to hyrax_image_path(solr_data[:id]) }
    end

    context 'when a matching url does not exist' do
      let(:url) { 'http://nope.example.com/this/doesnt/exist' }
      let(:solr_data) do
        {
          id: 'not-exist-test',
          has_model_ssim: ['Image'],
          title_tesim: ['This is not the thing we are looking for']
        }
      end

      it { is_expected.to have_http_status :not_found }
    end

    context 'when the item is a collection' do
      let(:url) { 'http://digital.lafayette.edu/collections/legacy-collection' }
      let(:solr_data) do
        {
          id: 'collection-test',
          has_model_ssim: ['Collection'],
          identifier_ssim: ["url:#{url}"]
        }
      end

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.collection_path(solr_data[:id]) }
    end
  end
end
