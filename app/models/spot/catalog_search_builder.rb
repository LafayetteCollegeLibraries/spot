# frozen_string_literal: true
module Spot
  class CatalogSearchBuilder < ::Hyrax::CatalogSearchBuilder
    include BlacklightAdvancedSearch::AdvancedSearchBuilder

    self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  end
end
