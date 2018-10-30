RSpec.describe Spot::CollectionFromConfig do
  subject(:collection) { described_class.new(attributes) }

  let(:attributes) do
    {
      title: title,
      metadata: metadata,
      collection_type: collection_type_id,
      visibility: visibility
    }
  end

  let(:title) { 'My cool collection' }
  let(:metadata) { { description: ['Some good words'] } }
  let(:collection_type_id) { 'user_collection' }
  let(:visibility) { 'private' }

  before do
    Collection.destroy_all
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

    context 'when "private"' do
      let(:visibility) { 'private' }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    end

    context 'it defaults to "public"' do
      let(:visibility) { 'i dunno?' }

      it { is_expected.to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end
  end

  describe '#create' do
    subject(:created) { collection.create }

    it { is_expected.to be_a Collection }

    context 'when metadata is provided' do
      let(:title) { 'a new collection' }
      let(:metadata) { { description: ['A very nice collction'] } }

      it 'passes it to the Collection' do
        expect(created.title).to eq [title]
        expect(created.description).to eq metadata[:description]
      end
    end
  end

  describe '.from_yaml' do
    subject(:created) { described_class.from_yaml(yaml) }

    let(:description) { 'a nice description' }
    let(:creator) { 'dss@lafayette.edu' }

    let(:yaml) do
      {
        'title' => title,
        'metadata' => {
          'description' => description,
          'creator' => creator
        }
      }
    end

    it 'wraps the metadata values in an array' do
      expect(created.metadata[:description]).to be_an Array
      expect(created.metadata[:creator]).to be_an Array
    end

    it 'converts metadata keys to symbols' do
      expect(created.metadata).to include :description
      expect(created.metadata).not_to include 'description'
      expect(created.metadata).to include :creator
      expect(created.metadata).not_to include 'creator'
    end
  end
end
