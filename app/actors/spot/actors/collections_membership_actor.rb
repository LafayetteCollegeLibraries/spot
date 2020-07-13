# frozen_string_literal: true
module Spot
  module Actors
    # Intended as a drop-in replacement for +Hyrax::Actors::CollectionsMembershipActor+.
    # When we add a work to a collection, we want to make sure that the work belongs
    # to all of the parent collections as well.
    #
    # @example replacing the actor in the stack
    #   # config/initializers/spot_overrides.rb (or wherever)
    #   Hyrax::CurationConcern.actor_factory.swap(Hyrax::Actors::CollectionsMembershipActor, Spot::Actors::CollectionsMembershipActor)
    #
    # This will affect create and update calls from the form.
    #
    class CollectionsMembershipActor < ::Hyrax::Actors::CollectionsMembershipActor
      private

        def add(env, id)
          collection = ::Collection.find(id)
          collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX

          return unless env.current_ability.can?(:deposit, collection)

          collection_ids = env.curation_concern.member_of_collections.map(&:id)
          collection_stack = [collection]

          until collection_stack.empty?
            col = collection_stack.shift

            next if collection_ids.include?(col.id)

            collection_ids << col.id
            env.curation_concern.member_of_collections << col
            collection_stack += col.member_of_collections
          end
        end
    end
  end
end
