# frozen_string_literal: true
RSpec.describe Hyrax::CollectionsController do
  routes { Hyrax::Engine.routes }

  # @todo
  #   It is my expectation/assumption that attempting to view a Collection that does not exist
  #   should result in a :not_found page being displayed. However, Hyrax will redirect the user
  #   home with a note about not having permission to view the object
  #   (see Hyrax::CollectionsControllerBehavior#curation_concern for loading). Note that this
  #   behavior only occurs in Hyrax::CollectionsController, and Hyrax::Dashboard::CollectionsController
  #   raises an ActiveFedora::ObjectNotFoundError as I would expect.
  #
  #   If this _were_ to raise the exception as expected, you could replace
  #   the entire block below with a call to the "it locates a colleciton with a slug identifier"
  #   shoared_example. Below is that example's code with the "not found"
  #   expectation swapped to expect Hyrax's behavior (redierct home with
  #   flash message).
  #
  #   @see spec/support/shared_examples/collection_controller_with_slugs.rb
  #   @see https://github.com/samvera/hyrax/blob/3.x-stable/app/controllers/concerns/hyrax/collections_controller_behavior.rb#L47-L54

  # it_behaves_like 'it locates a collection with a slug identifier'

  describe '#show' do
    before do
      Hyrax::Collections::PermissionsCreateService.create_default(collection: collection, creating_user: user)
      sign_in user
    end
    after { collection.destroy }

    let(:params) do
      {
        title: ['Cool Collection'],
        collection_type: Hyrax::CollectionType.find_or_create_default_collection_type,
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      }
    end
    let(:collection) { Collection.create(params.merge(identifier_params)) }
    let(:identifier_params) { {} }
    let(:user) { create(:public_user) }

    context 'when a collection has a slug' do
      let(:identifier_params) { { identifier: ["slug:#{slug}"] } }
      let(:slug) { 'cool-collection' }

      it 'loads the correct collection' do
        get :show, params: { id: slug }

        expect(response).to be_successful
        expect(assigns[:collection].id).to eq collection.id
      end
    end

    context 'when a collection does not have a slug' do
      it 'redirects to the home page with a permission error' do
        get :show, params: { id: 'nonesuch-collection' }

        expect(response.status).to eq 302
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
