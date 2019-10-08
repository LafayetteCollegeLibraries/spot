# frozen_string_literal: true
module Spot
  class CatalogSearchBuilder < ::Hyrax::CatalogSearchBuilder
    include BlacklightAdvancedSearch::AdvancedSearchBuilder
    include BlacklightRangeLimit::RangeLimitBuilder

    self.default_processor_chain -= [:show_works_or_works_that_contain_files]
    self.default_processor_chain += [:add_advanced_search_to_solr]
  end
end
