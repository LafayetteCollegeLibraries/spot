# frozen_string_literal: true
module Spot
  class CatalogSearchBuilder < ::Hyrax::CatalogSearchBuilder
    include BlacklightAdvancedSearch::AdvancedSearchBuilder
    include BlacklightRangeLimit::RangeLimitBuilder

    class_attribute :join_fields
    self.join_fields = %w[all_fields full_text]
    self.default_processor_chain += [:add_advanced_search_to_solr]

    # Rewrites +BlacklightAdvancedSearch::AdvancedSearch#add_advanced_search_to_solr+
    # so that a pre-existing +solr_parameters[:q]+ value isn't truncated by the
    # generated advanced query.
    #
    # @param [Hash<Symbol => *] solr_parameters
    # @return [void]
    def add_advanced_search_to_solr(solr_parameters)
      return unless is_advanced_search?
      parsed = BlacklightAdvancedSearch::QueryParser.new(blacklight_params, self.blacklight_config).to_solr

      solr_parameters[:q] = [solr_parameters[:q], parsed[:q]].reject(&:blank?).join(' ')
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] += parsed[:fq]
    end

    # Overridden from +Hyrax::CatalogSearchBuilder+ to expand the search fields
    # that are used to determine when to join file-sets. Also ensures that a
    # pre-existing +solr_parameters[:q]+ value isn't truncated by the join query.
    #
    # @param [Hash<Symbol => *] solr_parameters
    # @retrun [void]
    def show_works_or_works_that_contain_files(solr_parameters)
      return if blacklight_params[:q].blank? || !join_fields.include?(blacklight_params[:search_field])

      # if there's already a :user_query in place, don't overwrite it
      solr_parameters[:user_query] ||= blacklight_params[:q]
      solr_parameters[:q] = [solr_parameters[:q], new_query].reject(&:blank?).join(' ')
      solr_parameters[:defType] = 'lucene'
    end
  end
end
