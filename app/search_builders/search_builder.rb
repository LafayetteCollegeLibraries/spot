# frozen_string_literal: true
#
# Generated from +rails generate hyrax:install+
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  include BlacklightAdvancedSearch::AdvancedSearchBuilder

  # Add a filter query to restrict the search to documents the current user has access to
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
