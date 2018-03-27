RSpec.describe Hyrax::DocumentsController do
  context 'when visiting a known document' do
    let(:doc) { create(:document, :public) }

    before { get :show, params: { id: doc.id } }

    it { expect(response).to be_successful }
  end

  context 'when visiting a non-existant document' do
    # TODO: this shouldn't be raising an exception, but rather be rendering a 404

    it 'raises a Blacklight::RecordNotFound error' do
      expect { get :show, params: { id: 'not-here' } }
        .to raise_error(Blacklight::Exceptions::RecordNotFound)
    end
  end

  context 'when visiting a Private Document as a guest' do
    let(:doc) { create(:document, :private) }

    before { get :show, params: { id: doc.id } }

    it 'redirects to the login page' do
      expect(response.status).to eq 302
      expect(response.headers['Location']).to include '/users/sign_in'
    end
  end
end
