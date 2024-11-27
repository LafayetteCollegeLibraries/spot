# frozen_string_literal: true
module Spot
  # Applies a collection's permission template to all of its members. When adjusting a collection's
  # permissions, these aren't trickled down to the individual objects (understandably, it's a big operation).
  #
  # @example update permissions for all works in a collection
  #
  #   collection = Collection.find('abc123def')
  #   Spot::SyncCollectionPermissionsJob.perform_later(collection)
  #
  # @example reset the permissions for all works in a collection to match the collection's
  # permission_template (clears out edit + read groups/users)
  #
  #   collection = Collection.find('abc123def')
  #   Spot::SyncCollectionPermissionsJob.perform_later(collection, reset: true)
  #
  #
  # @todo Rewrite to use Hyrax ACL objects instead?
  # @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#permissions
  class SyncCollectionPermissionsJob < ApplicationJob
    # @param [Collection, Hyrax::PcdmCollection]
    # @param [Hash] options
    # @option [true, false] reset
    def perform(collection, reset: false)
      collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
      template = collection.permission_template

      members_of(collection).each do |member|
        reset_permissions_for(member) if reset == true

        Hyrax::PermissionTemplateApplicator.apply(template).to(model: member)
        member.permission_manager.acl.save # @note this will save the member object as well
      end

      true
    end

    private

    # Convenience method to make our lives easier when switching to Valkyrie.
    #
    # @param [Collection, Hyrax::PcdmCollection] collection
    # @return [Array<Hyrax::Resource>]
    def members_of(collection)
      Hyrax.query_service.custom_queries.find_members_of(collection: collection)
    end

    # Clears out edit groups/users and read groups/users for an item. Since permission_templates
    # don't appear to apply to discovery, we'll leave those go for now.
    #
    # @param [ActiveFedora::Base] item
    def reset_permissions_for(item)
      item.edit_groups = []
      item.edit_users = []
      item.read_groups = []
      item.read_users = []
    end
  end
end
