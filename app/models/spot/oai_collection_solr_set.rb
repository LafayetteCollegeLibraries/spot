# frozen_string_literal: true
module Spot
  class OaiCollectionSolrSet < ::BlacklightOaiProvider::SolrSet
    def self.from_spec(spec)
      new(spec.gsub(/_/, ' ')).solr_filter
    end

    def initialize(spec)
      super(spec.gsub(/_/, ' '))
    end

    def spec
      "#{@label}:#{@value.gsub(/\s/, '_')}"
    end
  end
end
