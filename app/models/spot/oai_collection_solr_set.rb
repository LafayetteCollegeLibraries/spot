# frozen_string_literal: true
module Spot
  # Subclass of +BlacklightOaiProvider::SolrSet+ that translates
  # spaces to underscores, making the following assumptions:
  #   a) we'll be using +member_of_collections_ssim+ as our only hook for OAI-PMG ListSets
  #   b) collection titles will never contain underscores
  class OaiCollectionSolrSet < ::BlacklightOaiProvider::SolrSet
    # @param [String] spec
    # @return [String] solr filter for set
    def self.from_spec(spec)
      new(spec.tr('_', ' ')).solr_filter
    end

    def initialize(spec)
      super(spec.tr('_', ' '))
    end

    def spec
      "#{@label}:#{@value.tr(' ', '_')}"
    end
  end
end
