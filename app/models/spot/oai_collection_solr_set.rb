# frozen_string_literal: true
require 'cgi'

module Spot
  # Subclass of +BlacklightOaiProvider::SolrSet+ that translates
  # spaces to underscores, making the following assumptions:
  #   a) we'll be using +member_of_collections_ssim+ as our only hook for OAI-PMG ListSets
  #   b) collection titles will never contain underscores
  class OaiCollectionSolrSet < ::BlacklightOaiProvider::SolrSet
    def self.sets_for(record)
      @fields = CatalogController.blacklight_config.oai[:document][:set_fields] if @fields.nil?

      super
    end

    def initialize(spec)
      super(CGI.unescape(spec))
    end

    def name
      "#{@label}: #{@value}"
    end

    def spec
      "#{@label}:#{CGI.escape(@value)}"
    end

    private

      def escape(value)
        CGI.escape(value)
      end

      def unescape(value)
        CGI.unescape(value)
      end
  end
end
