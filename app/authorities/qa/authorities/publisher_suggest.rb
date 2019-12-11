# frozen_string_literal: true
module Qa::Authorities
  # Authority to integrate Solr's suggestion service for publisher
  class PublisherSuggest < BaseSolrSuggest
    self.suggestion_dictionary = 'publisherSuggester'
  end
end
