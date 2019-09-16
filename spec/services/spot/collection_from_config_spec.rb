# frozen_string_literal: true
RSpec.describe Spot::CollectionFromConfig do
  subject(:collection) { described_class.new(attributes) }

  let(:base_attributes) do
    {
      title: title,
      metadata: metadata,
      collection_type: collection_type_id,
      visibility: visibility
    }
  end
  let(:attributes) { base_attributes }

  let(:title) { 'My cool collection' }
  let(:metadata) { { description: ['Some good words'] } }
  let(:collection_type_id) { 'user_collection' }
  let(:visibility) { 'private' }

  before do
    Hyrax::CollectionTypes::CreateService.create_admin_set_type
    Hyrax::CollectionTypes::CreateService.create_user_collection_type
  end

  after do
    Collection.destroy_all
  end

  describe 'collection_type' do
    subject(:type) { collection.collection_type }

    context 'when a type exists' do
      let(:collection_type_id) { Hyrax::CollectionType::ADMIN_SET_MACHINE_ID }

      it 'adds a Hyrax::CollectionType object with that machine_id' do
        expect(type.machine_id).to eq collection_type_id
      end
    end

    context 'when a type does not exist' do
      let(:collection_type_id) { 'no_not_here' }

      it do
        expect { type }.to raise_error(Spot::CollectionTypeDoesNotExistError)
      end
    end

    context 'when none provided' do
      let(:collection_type_id) { nil }

      it 'adds a default type (user_collection)' do
        expect(type.machine_id).to eq Hyrax::CollectionType::USER_COLLECTION_MACHINE_ID
      end
    end
  end

  describe 'visibility' do
    subject(:visibility) { collection.visibility }

    context 'when "authenticated"' do
      let(:visibility) { 'authenticated' }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
    end

    context 'when "public"' do
      let(:visibility) { 'public' }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    context 'it defaults to "private"' do
      let(:visibility) { 'i dunno?' }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    end
  end

  describe 'slug' do
    subject(:created) { collection.create_or_update!.identifier }

    context 'when present' do
      let(:attributes) { base_attributes.merge(slug: 'a-cool-collection') }

      it { is_expected.to eq ['slug:a-cool-collection'] }
    end

    context 'when not present' do
      it { is_expected.to eq [] }
    end
  end

  describe '#create_or_update!' do
    subject(:created) { collection.create_or_update! }

    it { is_expected.to be_a Collection }

    it 'creates a default permission_template' do
      expect(created.permission_template).not_to be nil
      expect(created.permission_template.access_grants).not_to be_empty
    end

    context 'when metadata is provided' do
      let(:title) { 'a new collection' }
      let(:metadata) { { description: ['A very nice collction'] } }

      it 'passes it to the Collection' do
        expect(created.title).to eq [title]
        expect(created.description).to eq metadata[:description]
      end
    end

    context 'when a collection already exists' do
      before { described_class.new(attributes).create_or_update! }

      let(:title) { 'A collection updated' }
      let(:metadata) { { description: ['An initial description'] } }
      let(:updated_attributes) { base_attributes.merge(metadata: { description: ['A different description'] }) }

      it 'updates the collection' do
        collection = described_class.new(updated_attributes).create_or_update!
        expect(collection.title).to include(title)
        expect(collection.description).to eq ['A different description']
      end
    end
  end

  describe '.from_yaml' do
    subject(:from_yaml) { described_class.from_yaml(yaml) }

    let(:description) { 'a nice description' }
    let(:creator) { 'dss@lafayette.edu' }

    let(:yaml) do
      {
        'title' => title,
        'metadata' => {
          'description' => description,
          'creator' => creator
        },
        'visibility' => 'authenticated',
        'slug' => 'cool-collection'
      }
    end

    it 'wraps the metadata values in an array' do
      expect(from_yaml.metadata[:description]).to be_an Array
      expect(from_yaml.metadata[:creator]).to be_an Array
    end

    it 'passes slug values on' do
      expect(from_yaml.slug).to eq 'cool-collection'
    end

    it 'passes visibility values' do
      expect(from_yaml.visibility).to eq 'authenticated'
    end

    it 'converts metadata keys to symbols' do
      expect(from_yaml.metadata).to include :description
      expect(from_yaml.metadata).not_to include 'description'
      expect(from_yaml.metadata).to include :creator
      expect(from_yaml.metadata).not_to include 'creator'
    end
  end
end
