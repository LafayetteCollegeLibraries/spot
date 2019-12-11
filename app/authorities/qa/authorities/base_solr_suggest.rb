# frozen_string_literal: true
module Qa::Authorities
  # An base class for building out local authorities to use Solr's
  # suggestion engine for autocomplete-options for fields.
  # This is a more flexible approach than using Blacklight's
  # suggestion search, which appears to only work for a single field.
  #
  # To begin, first ensure that a suggestion dictionary has been set-up + created
  # for your field. In +schemal.xml+, you'll want to ensure that a copyfield
  # has been created as the pool to draw from. Note: this field needs to be
  # a stored field.
  #
  # @example Configuring a copyfield for suggestions
  #   <copyField source="keyword_sim" dest="keyword_suggest_ssim" />
  #
  # In +solrconfig.xml+, you'll need to build a suggester. The property
  # +suggestAnalyzerFieldType+ should be a simple tokenizing field.
  #
  # @example Configuring a suggestion dictionary
  #   <lst name="suggester">
  #     <str name="name">keywordSuggester</str>
  #     <str name="lookupImpl">AnalyzingInfixLookupFactory</str>
  #     <str name="dictionaryImpl">DocumentDictionaryFactory</str>
  #     <str name="indexPath">suggestion_index_keyword</str>
  #     <str name="highlight">false</str>
  #     <str name="suggestAnalyzerFieldType">textSuggest</str>
  #     <!--
  #       buildOnCommit can bring ingests to a crawl, so we suggest
  #       leaving this false and manually triggering builds via
  #       a cron-job or something similar
  #     -->
  #     <str name="buildOnCommit">false</str>
  #     <str name="field">keyword_suggest_ssim</str>
  #   </lst>
  #
  # Finally, create a new authority which inherits from this, and
  # provide a value (the "name" in the suggestion dictionary config)
  # for the +suggestion_dictionary+ class_attribute.
  #
  # @example
  #   module Qa::Authorities
  #     class KeywordSuggest < BaseSolrSuggest
  #       self.suggestion_dictionary = 'keywordSuggester'
  #     end
  #   end
  #
  class BaseSolrSuggest < Qa::Authorities::Base
    class_attribute :suggestion_dictionary
    self.suggestion_dictionary = nil

    class << self
      # Triggers a build on the suggestion dictionary. If called
      # from this class - where suggestion_dictionary is nil -
      # it will trigger a build for all of the suggest dictionaries
      # (gives us a way of automating all of the builds).
      #
      # @return [void]
      def build_dictionary!
        params = { 'suggest' => true }

        if suggestion_dictionary.nil?
          params['suggest.buildAll'] = true
        else
          params['suggest.dictionary'] = suggestion_dictionary
          params['suggest.build'] = true
        end

        connection.get(suggest_path, params: params)
      end

      # @return [RSolr::Client]
      def connection
        ActiveFedora::SolrService.instance.conn
      end

      # @return [String]
      def suggest_path
        @suggest_path ||= begin
          url = Rails.application.config_for(:solr)['url']
          URI.join(url + '/', 'suggest').path
        end
      end
    end

    def search(query)
      solr_suggestion_for_query(query)
    end

    def term(_id)
      {}
    end

    def all
      []
    end

    # @param [String] query
    # @return [Array<Hash<String => String>>]
    def solr_suggestion_for_query(query)
      raise 'No suggestion dictionary provided!' if suggestion_dictionary.nil?

      params = {
        'suggest.q' => query,
        'suggest.dictionary' => suggestion_dictionary
      }

      raw = self.class.connection.get(self.class.suggest_path, params: params)
      parse_raw_response(raw, query: query)
    end

    private

      # Takes the Solr response and transforms the results into the
      # Questioning Authority preferred format.
      #
      # @param [Hash<String => *>] raw
      # @param [Hash] options
      # @option [String] query
      #   The initial query, used to extract results from the returned Hash
      # @return [Array<Hash<String => String>>]
      def parse_raw_response(raw, query:)
        suggestions = raw.dig('suggest', suggestion_dictionary, query, 'suggestions')
        suggestions ||= []

        suggestions.map do |res|
          { id: res['term'], label: res['term'], value: res['term'] }
        end
      end
  end
end
