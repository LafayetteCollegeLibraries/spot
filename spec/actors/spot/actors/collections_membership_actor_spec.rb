# frozen_string_literal: true
RSpec.describe Spot::Actors::CollectionsMembershipActor, actor_stack: true do
  before do
    allow(Collection).to receive(:find).with(parent_collection.id).and_return(parent_collection)
    allow(Collection).to receive(:find).with(child_collection.id).and_return(child_collection)

    allow(Hyrax::CollectionType).to receive(:for).with(collection: parent_collection).and_return(mock_collection_type)
    allow(Hyrax::CollectionType).to receive(:for).with(collection: child_collection).and_return(mock_collection_type)

    work.member_of_collections.clear
    child_collection.member_of_collections.clear
  end

  let(:mock_collection_type) { instance_double(Hyrax::CollectionType, share_applies_to_new_works?: true) }
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

# RSpec.describe Spot::Actors::CollectionsMembershipActor do
#   before do
#     allow(Hyrax.query_service)
#       .to receive(:find_by_alternate_identifier)
#       .with(alternate_identifier: parent_collection.id)
#       .and_return(parent_collection)

#     allow(Hyrax.query_service)
#       .to receive(:find_by_alternate_identifier)
#       .with(alternate_identifier: child_collection.id)
#       .and_return(child_collection)
#   end

#   let(:stack) { described_class.new(Hyrax::Actors::Terminator.new) }
#   let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }

#   let(:collection_class) { Hyrax.config.collection_class }
#   let(:parent_collection) { collection_class.new(id: 'parent-collection') }
#   let(:child_collection) { collection_class.new(id: 'child-collection') }
#   let(:work) { Publication.new(title: ['pub work']) }

#   let(:ability) { Ability.new(build(:admin_user)) }
#   let(:attributes) { { member_of_collections_attributes: collection_attributes } }

#   let(:collection_attributes) { { '0' => { 'id' => child_collection.id } } }

#   context 'when collection is an orphan' do
#     it 'sets the work as a member of that collection' do
#       expect(work.member_of_collection_ids).to eq []
#       stack.create(env)
#       expect(work.member_of_collection_ids).to eq [child_collection.id]
#     end
#   end

#   context 'when a collection belongs to another' do
#     before { parent_collection.member_ids << child_collection.id }

#     it 'sets the work as a member of both the intended collection and the parent' do
#       expect(work.member_of_collection_ids).to eq []
#       stack.create(env)
#       expect(work.member_of_collection_ids).to eq [child_collection, parent_collection]
#     end
#   end
# end
