# frozen_string_literal: true
RSpec.describe Spot::Actors::CollectionsMembershipActor do
  before do
    allow(Collection).to receive(:find).with(parent_collection.id).and_return(parent_collection)
    allow(Collection).to receive(:find).with(child_collection.id).and_return(child_collection)

    allow(parent_collection).to receive(:share_applies_to_new_works?).and_return true
    allow(child_collection).to receive(:share_applies_to_new_works?).and_return true

    work.member_of_collections.clear
    child_collection.member_of_collections.clear
  end

  let(:stack) { described_class.new(Hyrax::Actors::Terminator.new) }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }

  let(:parent_collection) { Collection.new(id: 'parent-collection') }
  let(:child_collection) { Collection.new(id: 'child-collection') }
  let(:work) { Publication.new(title: ['pub work']) }

  let(:ability) { Ability.new(build(:admin_user)) }
  let(:attributes) { { member_of_collections_attributes: collection_attributes } }

  let(:collection_attributes) { { '0' => { 'id' => child_collection.id } } }

  context 'when collection is an orphan' do
    it 'sets the work as a member of that collection' do
      expect(work.member_of_collections).to eq []
      stack.create(env)
      expect(work.member_of_collections).to eq [child_collection]
    end
  end

  context 'when a collection belongs to another' do
    before { child_collection.member_of_collections << parent_collection }

    it 'sets the work as a member of both the intended collection and the parent' do
      expect(work.member_of_collections).to eq []
      stack.create(env)
      expect(work.member_of_collections).to eq [child_collection, parent_collection]
    end
  end
end
