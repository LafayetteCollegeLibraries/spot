# frozen_string_literal: true
module Spot
  # A service for dealing with embargoes and leases. Right now, we're just
  # using this to clear out expired items.
  #
  # @example Clear out all expired values at once
  #   Spot::EmbargoLeaseService.clear_all_expired
  #
  # @example Clear out expired embargoes (and update +date_available+ values)
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
          resource = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: presenter.id)
          manager = Hyrax::EmbargoManager.new(resource: resource)
          next unless manager.release

          Hyrax.persister.save(resource: resource)
          # next if resource.file_set?

          copy_visibility_to_files(resource: resource)

          RegenerateThumbnailJob.perform_later(resource) if regenerate_thumbnails == true
        end
      end

      # Clears out expired leases
      #
      # @return [void]
      def clear_expired_leases(regenerate_thumbnails: false)
        ::Hyrax::LeaseService.assets_with_expired_leases.each do |presenter|
          resource = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: presenter.id)
          manager = Hyrax::LeaseManager.new(resource: resource)
          next unless manager.release

          Hyrax.persister.save(resource: resource)
          # next if resource.file_set?

          copy_visibility_to_files(resource: resource)

          RegenerateThumbnailJob.perform_later(resource) if regenerate_thumbnails == true
        end
      end

      def copy_visibility_to_files!(resource:)
        Hyrax.query_service.find_members(resource: resource).each do |member|
          Hyrax::AccessControlList.copy_permissions(source: resource, target: member)
        end
      end
    end
  end
end
