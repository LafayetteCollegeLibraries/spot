# frozen_string_literal: true
RSpec.describe Hyrax::CollectionsController do
  routes { Hyrax::Engine.routes }

  describe '#show' do
    let(:params) do
      {
        title: ['Cool Collection'],
        collection_type: Hyrax::CollectionType.find_or_create_default_collection_type,
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      }
    end

    context 'when a collection has a slug' do
      before { collection }
      after { collection.destroy }

      let(:collection) { Collection.create(params.merge(identifier: ["slug:#{slug}"])) }
      let(:slug) { 'cool-collection' }

      it 'loads the correct collection' do
        get :show, params: { id: slug }

        expect(response).to be_successful
        expect(assigns[:curation_concern].id).to eq collection.id
      end
    end
  end
end
