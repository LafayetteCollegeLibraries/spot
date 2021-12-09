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
  class SyncCollectionPermissionsJob < ApplicationJob
    # @param [Collection]
    # @param [Hash] options
    # @option [true, false] reset
    def perform(collection, reset: false)
      template = collection.permission_template

      members_of(collection).each do |member|
        reset_permissions_for(member) if reset == true

        Hyrax::PermissionTemplateApplicator.apply(template).to(model: member)
        member.save
      end

      true
    end

  private

    # Convenience method to make our lives easier when switching to Valkyrie.
    #
    # @param [Collection] collection
    def members_of(collection)
      ActiveFedora::Base.where(member_of_collection_ids_ssim: collection.id)
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
