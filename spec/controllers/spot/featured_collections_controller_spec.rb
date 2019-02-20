# frozen_string_literal: true
#
# These are (essentially) copied from
# https://github.com/samvera/hyrax/blob/e36ddb4/spec/controllers/hyrax/featured_works_controller_spec.rb
RSpec.describe Spot::FeaturedCollectionsController do
  let(:user) { create(:admin_user) }

  describe '#create' do
    before do
      sign_in user

      allow(controller)
        .to receive(:authorize!)
        .with(:create, FeaturedCollection)
        .and_return(true)
    end

    context 'when there are no featured collections' do
      it 'creates one' do
        expect do
          post :create, params: { id: 'abc123', format: :json }
        end.to change { FeaturedCollection.count }.by(1)

        expect(response).to be_successful
      end
    end

    context 'when there are 4 featured collections' do
      before do
        4.times { |n| FeaturedCollection.create(collection_id: n.to_s) }
      end

      after { FeaturedCollection.destroy_all }

      it 'does not create another' do
        expect do
          post :create, params: { id: 'abc123', format: :json }
        end.not_to change { FeaturedCollection.count }

        expect(response.status).to eq 422
      end
    end
  end

  describe '#destroy' do
    before do
      sign_in user

      allow(controller)
        .to receive(:authorize!)
        .with(:destroy, FeaturedCollection)
        .and_return true
    end

    context 'when the collection exists' do
      before { FeaturedCollection.create(collection_id: 'abc123') }

      it 'removes it' do
        expect do
          delete :destroy, params: { id: 'abc123', format: :json }
        end.to change { FeaturedCollection.count }.by(-1)

        expect(response.status).to eq 204
      end
    end

    context 'when it was already removed' do
      it "doesn't raise an error" do
        delete :destroy, params: { id: 'abc123', format: :json }
        expect(response.status).to eq 204
      end
    end
  end
end
