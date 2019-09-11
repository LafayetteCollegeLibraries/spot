# frozen_string_literal: true
module Spot
  # Mixin to add support for preferring slugs to IDs for Collections
  module CollectionSlugsBehavior
    # Overrides the default behavior by first trying the ID as a stored slug.
    # If it doesn't exist, we'll rely on default behavior to find it by ID.
    def show
      @curation_concern =
        ActiveFedora::Base.where(collection_slug_ssi: params[:id]).first

      # This goes against the grain for me, but the permission document
      # is searched using +params[:id]+, which it expects to be an ID
      # (rather than a slug), so we'll need to reset that param with
      # our collection's ID, if we found a match.
      params[:id] = @curation_concern.id unless @curation_concern.nil?

      super
    end
  end
end
