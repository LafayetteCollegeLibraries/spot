# frozen_string_literal: true
RSpec.describe Spot::Listeners::ParentCollectionMembershipListener, valkyrization: true do
  let(:listener) { described_class.new }
  let(:user) { build(:admin_user) }

  # @todo should these be factories?
  let(:parent_collection) { Hyrax::PcdmCollection.new(id: 'parent', title: ['Parent Collection']) }
  let(:child_collection) { Hyrax::PcdmCollection.new(id: 'child', title: ['Child Collection'], member_of_collection_ids: ['parent']) }
  let(:resource) { build(:publication_resource, **metadata) }

  before do
    allow(Hyrax.query_service)
      .to receive(:find_by_alternate_identifier)
      .with(alternate_identifier: 'parent')
      .and_return(parent_collection)

    allow(Hyrax.query_service)
      .to receive(:find_by_alternate_identifier)
      .with(alternate_identifier: 'child')
      .and_return(child_collection)

    allow(Hyrax.persister).to receive(:save)
  end

  describe '#on_object_metadata_updated' do
    context 'when the resource belongs to a collection' do
      let(:metadata) { { member_of_collection_ids: ['child'] } }

      it 'it adds the parent collection id to resource#member_of_collection_ids' do
        expect { listener.on_object_metadata_updated(object: resource, user: user) }
          .to change { resource.member_of_collection_ids }
          .from(['child'])
          .to(['child', 'parent'])

        expect(Hyrax.persister).to have_received(:save).with(resource: resource)
      end
    end

    context 'when the resource does not belong to a collection' do
      let(:metadata) { {} }

      it 'does nothing' do
        expect { listener.on_object_metadata_updated(object: resource, user: user) }
          .not_to change { resource.member_of_collection_ids }
      end
    end
  end
end
