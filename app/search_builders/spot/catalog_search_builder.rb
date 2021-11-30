# frozen_string_literal: true
module Spot
  # Our expansion of the +Hyrax::CatalogSearchBuilder+ to add Blacklight
  # plugins (blacklight_advanced_search and blacklight-range_limit), remove
  # the Hyrax join query for extracted text, and conditionally (for now)
  # display highlight matches (where present).
  class CatalogSearchBuilder < ::Hyrax::CatalogSearchBuilder
    include BlacklightAdvancedSearch::AdvancedSearchBuilder
    include BlacklightRangeLimit::RangeLimitBuilder

    self.default_processor_chain -= [:show_works_or_works_that_contain_files]
    self.default_processor_chain += [
      :add_advanced_search_to_solr,
      :conditionally_add_full_text_context
    ]

    # Adds highlight field params if a query was passed
    # to the search parameters.
    #
    # @params [Blacklight::Solr::Request] solr_parameters
    # @return [void]
    def conditionally_add_full_text_context(params)
      return unless blacklight_params[:q].present?

      params['hl'] = true
      params['hl.fl'] ||= []
      params['hl.fl'] << 'extracted_text_tsimv'
    end
  end
end
