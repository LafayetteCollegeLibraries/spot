# frozen_string_literal: true
module Spot
  # Updates +Collection#add_member_objects+ behavior by adding works to
  # this collection as well as any parent collections.
  #
  # @example
  #   class Collection < ActiveFedora::Base
  #     include Hyrax::CollectionBehavior
  #     include Spot::NestedCollectionBehavior
  #
  #   end
  #
  #   # note: Collection.create doesn't work like this, but let's pretend it does
  #   col_1 = Collection.create(title: ['Parent Collection'])
  #   col_2 = Collection.create(title: ['Child Collection'])
  #
  #   col_2.member_of_collections << col_1
  #
  #   work = Publication.create(title: ['Publication Work'])
  #   col_2.add_member_objects(work.id)
  #
  #   work.member_of_collections.include?(col_2)
  #   # => true
  #   work.member_of_collections.include?(col_1)
  #   # => true
  module NestedCollectionBehavior
    # Add items to a collection via their id values
    #
    # @param [Array<String>, String] new_member_ids
    # @return [Array<ActiveFedora::Base>]
    def add_member_objects(new_member_ids)
      collections_to_add = gather_collections_to_add
      collection_ids_to_add = collections_to_add.map(&:id)

      Array(new_member_ids).collect do |member_id|
        member = find_member_by_id(member_id)
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

    # Go down (up?) the family tree until there are no more parent collections to add
    #
    # @return [Array<Collection>]
    def gather_collections_to_add
      collections_to_check = [self]

      [].tap do |collections|
        until collections_to_check.size.zero?
          col = collections_to_check.shift

          collections << col unless collections.include?(col)
          collections_to_check += col.member_of_collections
        end
      end
    end

    # @param [String] id
    # @return [Hyrax::Resource]
    def find_member_by_id(id)
      Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id, use_valkyrie: false)
    end

    # just a wrapper to clean up +#add_member_objects+
    def check_multiple_membership(item:, collection_ids:)
      Hyrax::MultipleMembershipChecker.new(item: item).check(collection_ids: collection_ids, include_current_members: true)
    end
  end
end
