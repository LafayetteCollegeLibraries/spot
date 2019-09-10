# frozen_string_literal: true
module Spot
  # Mixin to add support for preferring slugs to IDs for Collections
  module CollectionSlugsBehavior
    # Overrides the default behavior by first trying the ID as a stored slug.
    # If it doesn't exist, we'll rely on default behavior to find it by ID.
    def show
      @curation_concern =
        ActiveFedora::Base.where(collection_slug_ss: params[:id]).first

      super
    end
  end
end
