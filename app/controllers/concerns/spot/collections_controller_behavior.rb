# frozen_string_literal: true
module Spot
  # Common Collections behavior to be mixed in with Hyrax::CollectionsController and
  # Hyrax::Dashboard::CollectionsController.
  #
  # - adds the ability to load a collection from a slug identifier (on :show requests)
  # - changes the sort fields for collection items (default is title sort, ascending)
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern

    included do
      prepend_before_action :load_collection_from_slug, only: [:show]

      configure_blacklight do |config|
        # clear out sort_fields from CatalogController
        config[:sort_fields] = ActiveSupport::OrderedHash.new

        config.add_sort_field 'title_sort_si asc', label: "Title \u25B2"
        config.add_sort_field 'title_sort_si desc', label: "Title \u25BC"
        config.add_sort_field 'date_sort_dtsi asc', label: "Date \u25B2"
        config.add_sort_field 'date_sort_dtsi desc', label: "Date \u25BC"
      end
    end

    def load_collection_from_slug
      @collection = Collection.where(collection_slug_ssi: params[:id]).first
      params[:id] = @collection.id unless @collection.nil?
    end
  end
end
