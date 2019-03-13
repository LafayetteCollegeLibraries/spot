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
end
