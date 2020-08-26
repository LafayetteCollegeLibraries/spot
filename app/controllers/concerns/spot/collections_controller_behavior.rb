# frozen_string_literal: true
module Spot
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern

    include CollectionSlugsBehavior

    included do
      configure_blacklight do |config|
        # clear out sort_fields from CatalogController
        config[:sort_fields] = ActiveSupport::OrderedHash.new

        config.add_sort_field 'title_sort_si asc', label: "Title \u25B2"
        config.add_sort_field 'title_sort_si desc', label: "Title \u25BC"
        config.add_sort_field 'date_sort_dtsi asc', label: "Date \u25B2"
        config.add_sort_field 'date_sort_dtsi desc', label: "Date \u25BC"
      end
    end
  end
end
