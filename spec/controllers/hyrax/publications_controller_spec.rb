RSpec.describe Hyrax::PublicationsController do
  context 'when visiting a known publication' do
    let(:doc) { create(:publication, :public) }

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
end
