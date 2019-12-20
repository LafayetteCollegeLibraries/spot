# frozen_string_literal: true
module Spot
  # Job to update the Solr suggestion engine's dictionaries
  class UpdateSolrSuggestDictionariesJob < ::ApplicationJob
    # @return [void]
    def perform
      ::Qa::Authorities::SolrSuggest.build_dictionaries!
    end
  end
end
