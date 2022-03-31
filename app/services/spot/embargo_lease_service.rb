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
  #
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
          item = ActiveFedora::Base.find(presenter.id)

          next if item.under_embargo?

          ::Hyrax::Actors::EmbargoActor.new(item).destroy

          next if item.is_a? FileSet

          item.copy_visibility_to_files
          item.save!

          RegenerateThumbnailJob.perform_later(item) if regenerate_thumbnails == true
        end
      end

      # Clears out expired leases
      #
      # @return [void]
      def clear_expired_leases(regenerate_thumbnails: false)
        ::Hyrax::LeaseService.assets_with_expired_leases.each do |presenter|
          item = ActiveFedora::Base.find(presenter.id)

          next if item.active_lease?

          ::Hyrax::Actors::LeaseActor.new(item).destroy

          item.copy_visibility_to_files unless item.is_a? FileSet

          RegenerateThumbnailJob.perform_later(item) if regenerate_thumbnails == true
        end
      end
    end
  end
end
