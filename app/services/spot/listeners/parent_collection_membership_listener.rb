# frozen_string_literal: true
module Spot
  module Listeners
    # Listener to ensure that an object in a child collection is also included in the parent collection.
    # Intended to replace Spot::Actors::CollectionsMembershipActor
    class ParentCollectionMembershipListener
      # @return [void]
      def on_object_metadata_updated(event)
        object = event[:object]
        return if object.blank? || object.try(:member_of_collection_ids).blank?

        collection_ids_to_add = parent_collection_ids_for(object.member_of_collection_ids)
        return if collection_ids_to_add.empty?

        object.member_of_collection_ids += collection_ids_to_add
        Hyrax.persister.save(resource: object)
      end

      private

      def parent_collection_ids_for(initial_collections)
        collections_to_check = initial_collections.to_a
        collection_ids_to_add = []

        until collections_to_check.empty?
          col_id = collections_to_check.shift
          collection_ids_to_add << col_id

          collections_to_check += collection_ids_for(col_id)
          collections_to_check.uniq!
        end

        collection_ids_to_add - initial_collections
      end

      def collection_ids_for(collection_id)
        collection = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: collection_id)
        collection.try(:member_of_collection_ids) || []
      end
    end
  end
end
