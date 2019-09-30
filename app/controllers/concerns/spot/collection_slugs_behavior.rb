# frozen_string_literal: true
module Spot
  # Mixin to add support for preferring slugs to IDs for Collections.
  # Conducts a search for a collection using a stored-string field in solr,
  # and, upon success, rewrites the +params[:id]+ value to the correct
  # ID. This needs to be performed as early as possible (using +:prepend_before_action+)
  # so that the +params[:id]+ can be reset to a NOID for things like
  # permissions checking.
  module CollectionSlugsBehavior
    extend ActiveSupport::Concern

    included do
      prepend_before_action :load_collection, only: [:show]
    end

    # @return [void]
    def load_collection
      @curation_concern = Collection.where(collection_slug_ssi: params[:id]).first
      params[:id] = @curation_concern.id unless @curation_concern.nil?
    end
  end
end
