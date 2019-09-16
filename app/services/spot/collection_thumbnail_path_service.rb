# frozen_string_literal: true
module Spot
  class CollectionThumbnailPathService < ::Hyrax::CollectionThumbnailPathService
    # Tries to find a 'logo'-roled +CollectionBrandingInfo+ item
    # and falls-back on the super-class method.
    #
    # @param [Collection] object
    # @return [String]
    def self.call(object)
      branding = CollectionBrandingInfo.where(collection_id: object.id, role: 'logo')
      return super if branding.empty?

      # prefer the first 'logo' item + use the string-manipulation
      # from +Hyrax::CollectionPresenter+
      # @see: https://github.com/samvera/hyrax/blob/v2.5.1/app/presenters/hyrax/collection_presenter.rb#L123
      "/" + branding.first.local_path.split("/")[-4..-1].join("/")
    end
  end
end
