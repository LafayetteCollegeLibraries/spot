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
      def clear_all_expired
        clear_expired_embargoes && clear_expired_leases
      end

      # Clears out expired embargoes and sets the +date_available+ property
      # to today's date.
      #
      # @return [void]
      def clear_expired_embargoes
        ::Hyrax::EmbargoService.assets_with_expired_embargoes.each do |presenter|
          item = ActiveFedora::Base.find(presenter.id)

          # set date_available now, if applicable (FileSets are also under embargo
          # but don't have the property). we'll do this before calling the
          # EmbargoActor because the actor calls +item.save+.
          item.date_available = [Time.zone.now.strftime('%Y-%m-%d')] if item.respond_to?(:date_available=)

          ::Hyrax::Actors::EmbargoActor.new(item).destroy
        end
      end

      # Clears out expired leases
      #
      # @return [void]
      def clear_expired_leases
        ::Hyrax::LeaseService.assets_with_expired_leases.each do |presenter|
          item = ActiveFedora::Base.find(presenter.id)

          ::Hyrax::Actors::LeaseActor.new(item).destroy
        end
      end
    end
  end
end
