# frozen_string_literal: true
module Qa::Authorities
  # Authority to integrate Solr's suggestion service for sources
  class SourceSuggest < BaseSolrSuggest
    self.suggestion_dictionary = 'sourceSuggester'
  end
end
