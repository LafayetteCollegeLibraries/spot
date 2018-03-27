RSpec.describe Hyrax::TrusteeDocumentsController do
  let(:user) { create(:trustee_user) }
  let(:doc) { create(:trustee_document, user: user) }

  context 'when visiting a known document' do
    before do
      sign_in user
      get :show, params: { id: doc.id }
    end

    it { expect(response).to be_successful }
  end

  context 'when visiting a non-existant TrusteeDocument' do
    # TODO: this shouldn't be raising an exception, but rather be rendering a 404

    it 'raises a Blacklight::RecordNotFound error' do
      expect { get :show, params: { id: 'not-here' } }
        .to raise_error(Blacklight::Exceptions::RecordNotFound)
    end
  end

  context 'when visiting a Trustee Document as a guest/non-trustee user' do
    let(:user) { create(:user) }
    let(:doc) { create(:trustee_document) }

    # TODO: skipping until we figure out auth issues with TrusteeDocuments
    skip 'returns Unauthorized' do
      expect(response.status).to eq 401
      expect(response.message).to eq 'Unauthorized'
    end
  end
end
