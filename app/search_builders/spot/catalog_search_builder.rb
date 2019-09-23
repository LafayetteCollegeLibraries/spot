# frozen_string_literal: true
module Spot
  class CatalogSearchBuilder < ::Hyrax::CatalogSearchBuilder
    include BlacklightAdvancedSearch::AdvancedSearchBuilder
    include BlacklightRangeLimit::RangeLimitBuilder

    class_attribute :join_fields
    self.join_fields = %w[all_fields full_text]
    self.default_processor_chain += [:add_advanced_search_to_solr]

    # Overridden from +Hyrax::CatalogSearchBuilder+ to expand the search fields
    # that are used to determine when to join file-sets.
    #
    # @param [Hash<Symbol => *]
    # @retrun [void]
    def show_works_or_works_that_contain_files(solr_parameters)
      return if blacklight_params[:q].blank? || !join_fields.include?(blacklight_params[:search_field])
      solr_parameters[:user_query] = blacklight_params[:q]
      solr_parameters[:q] = new_query
      solr_parameters[:defType] = 'lucene'
    end
  end
end
