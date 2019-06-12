# frozen_string_literal: true
RSpec.describe Hyrax::PublicationsController do
  let(:doc) { create(:publication, :public) }

  context 'when visiting a known publication' do
    before do
      get :show, params: { id: doc.id }
    end

    it { expect(response).to be_successful }
  end

  context 'when visiting a non-existant publication' do
    # TODO: this shouldn't be raising an exception, but rather be rendering a 404

    it 'raises a Blacklight::RecordNotFound error' do
      expect { get :show, params: { id: 'not-here' } }
        .to raise_error(Blacklight::Exceptions::RecordNotFound)
    end
  end

  context 'when visiting a Private Publication as a guest' do
    let(:doc) { create(:publication, :private) }

    before do
      get :show, params: { id: doc.id }
    end

    it 'redirects to the login page' do
      expect(response.status).to eq 302
      expect(response.headers['Location']).to include '/users/sign_in'
    end
  end

  context 'when requesting the metadata as csv' do
    let(:disposition)  { response.header.fetch('Content-Disposition') }
    let(:content_type) { response.header.fetch('Content-Type') }

    it 'downloads the file' do
      get :show, params: { id: doc.id, format: 'csv' }

      expect(response).to be_successful
      expect(disposition).to include 'attachment'
      expect(content_type).to eq 'text/csv'
      expect(response.body).to start_with('id,title')
    end
  end

  # test iiif manifest cache
  context 'when requesting the iiif manifest of an item' do
    before do
      allow(IIIFManifest::ManifestFactory).to receive(:new)
        .with(presenter)
        .and_return(manifest_factory)

      allow(controller).to receive(:presenter).and_return(presenter)

      Rails.cache.clear
    end

    let(:doc) { instance_double(ActiveFedora::Base, id: 'abc123def') }
    let(:manifest_factory) { instance_double(IIIFManifest::ManifestBuilder, to_h: { test: 'manifest' }) }
    let(:presenter) { instance_double(Hyrax::WorkShowPresenter, id: doc.id, solr_document: solr_document) }
    let(:solr_document) { {'_version_' => 12345678 } }
    let(:cache_key) { "#{doc.id}/12345678" }

    it 'adds the doc to the cache' do
      expect(Rails.cache.exist?(cache_key)).to be false

      get :manifest, params: { id: doc.id }

      expect(Rails.cache.exist?(cache_key)).to be true
    end
  end
end
