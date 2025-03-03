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

  # Overriding Hyrax::SearchBuilder#work_types to include our Valkyrized Resource classes,
  # rather than registering them in config/initializers/hyrax.rb because registering adds
  # unwanted behaviors (such as adding dupicate work types to the create works modal).
  #
  # @return [Array<Class>]
  def work_types
    Hyrax.config.curation_concerns.flat_map do |concern_class|
      [concern_class, "#{concern_class}Resource".safe_constantize].compact
    end
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
