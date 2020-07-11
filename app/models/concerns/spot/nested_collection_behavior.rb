# frozen_string_literal: true
module Spot
  module NestedCollectionBehavior
    # @todo update after updating to hyrax@3
    def add_member_objects(new_member_ids)
      collections_to_add = [self] + member_of_collections
      collection_ids_to_add = [id] + member_of_collection_ids

      Array(new_member_ids).collect do |member_id|
        member = member_query_service(member_id)
        message = check_multiple_membership(item: member, collection_ids: collection_ids_to_add)

        if message
          member.errors.add(:collections, message)
        else
          member.member_of_collections += collections_to_add
          member.save!
        end

        member
      end
    end

    private

      # @todo replace with just a call to +find_by_alternate_id+ after we upgrade to hyrax@3
      #       and start switching to Wings
      def member_query_service(id)
        if Hyrax.respond_to?(:query_service)
          Hyrax.query_service.find_by_alternate_id(alternate_id: id, use_valkyrie: false)
        else
          ActiveFedora::Base.find(id)
        end
      end

      def check_multiple_membership(item:, collection_ids:)
        Hyrax::MultipleMembershipChecker.new(item: item).check(collection_ids: collection_ids, include_current_members: true)
      end
  end
end
