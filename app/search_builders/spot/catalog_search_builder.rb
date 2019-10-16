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

    # Allows us to toggle highlighting on the extracted_text field,
    # rather than defining the field within the CatalogController.
    # This way we can preview the behavior first rather than exposing
    # it and possibly having to remove it for performance reasons.
    #
    # @params [Blacklight::Solr::Request] solr_parameters
    # @return [void]
    def conditionally_add_full_text_context(params)
      return unless display_full_text_context?

      params['hl'] = true
      params['hl.fl'] ||= []
      params['hl.fl'] << 'extracted_text_tsimv'
    end

    private

      # @return [true, false]
      def display_full_text_context?
        Flipflop.enabled?(:search_result_contextual_match) && blacklight_params[:q].present?
      end
  end
end
