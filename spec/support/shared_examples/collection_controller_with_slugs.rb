# frozen_string_literal: true
RSpec.shared_examples 'it locates a collection with a slug identifier' do |options|
  options ||= {}
  options.reverse_merge!(user: :public_user)

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
    let(:user) { create(options[:user]) }

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
      it 'returns not found' do
        expect { get :show, params: { id: 'nonesuch-collection' } }.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end
end
