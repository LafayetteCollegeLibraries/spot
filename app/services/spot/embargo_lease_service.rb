# frozen_string_literal: true
module Spot
  # A service for dealing with embargoes and leases. Right now, we're just
  # using this to clear out expired items.
  #
  # @example Clear out all expired values at once and regenerate thumbnails
  #   Spot::EmbargoLeaseService.clear_all_expired(regenerate_thumbnails: true)
  #
  # @example Clear out expired embargoes
  #   Spot::EmbargoLeaseService.clear_expired_embargoes
  #
  # @example Clear out expired leases
  #   Spot::EmbargoLeaseService.clear_expired_leases

  class EmbargoLeaseService
    class << self
      # Convenience method to clear both embargoes and leases
      #
      # @return [void]
      # @see {.clear_expired_embargoes}
      # @see {.clear_expired_leases}
      def clear_all_expired(regenerate_thumbnails: false)
        clear_expired_embargoes(regenerate_thumbnails: regenerate_thumbnails) && clear_expired_leases(regenerate_thumbnails: regenerate_thumbnails)
      end

      # Clears out expired embargoes
      #
      # @return [void]
      def clear_expired_embargoes(regenerate_thumbnails: false)
        ::Hyrax::EmbargoService.assets_with_expired_embargoes.each do |presenter|
          release_and_save_for_id(presenter.id, type: :embargo, regenerate_thumbnails: regenerate_thumbnails)
        end
      end

      # Clears out expired leases
      #
      # @return [void]
      def clear_expired_leases(regenerate_thumbnails: false)
        ::Hyrax::LeaseService.assets_with_expired_leases.each do |presenter|
          release_and_save_for_id(presenter.id, type: :lease, regenerate_thumbnails: regenerate_thumbnails)
        end
      end

      private

      # Embargos and Leases behave very similarly and are managed through similar interfaces
      # in Hyrax, so we'll do the bulk of that work here.
      #
      # @param [String] id
      # @option [:embargo, :lease] :type
      # @option [true/false] :regenerate_thumbnails
      # @return [void]
      def release_and_save_for_id(id, type:, regenerate_thumbnails: false)
        resource = release_and_save_acl_for(type: type, resource: Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id))
        return if resource.nil?

        copy_visibility_to_members!(resource: resource)

        RegenerateThumbnailJob.perform_later(resource) if regenerate_thumbnails == true
      end

      # calling #release! on the managers will raise a +NotReleaseableError+ if
      # the embargo/lease isn't ready to be deactivated. Since the resource's
      # visibility hasn't changed, we won't bother to resave the object or enqueue
      # a thumbnail regeneration job.
      #
      # @todo how can we test the `nil` return value for coverage?
      def release_and_save_acl_for(type:, resource:)
        manager_class = manager_class_for(type)
        return if manager_class.nil?

        manager_class.new(resource: resource).release!
        resource.permission_manager.acl.save
        resource
      rescue Hyrax::EmbargoManager::NotReleasableError, Hyrax::LeaseManager::NotReleasableError
        # :nocov:
        # This is covered via other tests
        nil
        # :nocov:
      end

      def manager_class_for(type)
        case type
        when :embargo
          Hyrax::EmbargoManager
        when :lease
          Hyrax::LeaseManager
        end
      end

      def copy_visibility_to_members!(resource:)
        Hyrax.query_service.find_members(resource: resource).each do |member|
          Hyrax::AccessControlList.copy_permissions(source: resource, target: member)
        end
      end

      private

      # Embargos and Leases behave very similarly and are managed through similar interfaces
      # in Hyrax, so we'll do the bulk of that work here.
      #
      # @param [String] id
      # @option [:embargo, :lease] :type
      # @option [true/false] :regenerate_thumbnails
      # @return [void]
      def release_and_save_for_id(id, type:, regenerate_thumbnails: false)
        resource = release_and_save_acl_for(type: type, resource: Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id))
        return if resource.nil?

        copy_visibility_to_members!(resource: resource)

        RegenerateThumbnailJob.perform_later(resource) if regenerate_thumbnails == true
      end

      # calling #release! on the managers will raise a +NotReleaseableError+ if
      # the embargo/lease isn't ready to be deactivated. Since the resource's
      # visibility hasn't changed, we won't bother to resave the object or enqueue
      # a thumbnail regeneration job.
      #
      # @todo how can we test the `nil` return value for coverage?
      def release_and_save_acl_for(type:, resource:)
        manager_class = manager_class_for(type)
        return if manager_class.nil?

        manager_class.new(resource: resource).release!
        resource.permission_manager.acl.save
        resource
      rescue Hyrax::EmbargoManager::NotReleasableError, Hyrax::LeaseManager::NotReleasableError
        # :nocov:
        # This is covered via other tests
        nil
        # :nocov:
      end

      def manager_class_for(type)
        case type
        when :embargo
          Hyrax::EmbargoManager
        when :lease
          Hyrax::LeaseManager
        end
      end

      # :nocov:
      # return to this post valkyrization
      def copy_visibility_to_members!(resource:)
        Hyrax.query_service.find_members(resource: resource).each do |member|
          Hyrax::AccessControlList.copy_permissions(source: resource, target: member)
        end
      end
      # :nocov:
    end
  end
end
