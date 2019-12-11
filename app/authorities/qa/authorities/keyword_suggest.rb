# frozen_string_literal: true
module Qa::Authorities
  # Authority to integrate Solr's suggestion service for keywords
  class KeywordSuggest < BaseSolrSuggest
    self.suggestion_dictionary = 'keywordSuggester'
  end
end
