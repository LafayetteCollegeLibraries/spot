# frozen_string_literal: true
module Spot
  class UnpaywallSearchService
    class DOINotFound < StandardError; end
    class NoOSOption < StandardError; end
    class SearchError < StandardError; end

    include Singleton

    API_BASE_URL = 'https://api.unpaywall.org'

    class_attribute :email_address
    self.email_address = 'dss@lafayette.edu'

    # @see #find
    def self.find(doi)
      instance.find(doi)
    end

    # Conducts the search and parses the response
    #
    # @see #parse_response
    def find(doi)
      response = connection.get("/v2/#{doi}")
      parse_response(response.body)
    end

    private

      # @return [Faraday::Connection]
      def connection
        @connection ||= Faraday.new(url: API_BASE_URL, params: { email: email_address })
      end

      # @param [Hash] body
      # @return [Hash<Symbol => String, Array<String>>]
      # @raise DOINotFound Raised if the return status is 404
      # @raise SearchError Raised if the response has an 'error' but isn't a 404
      # @raise NoOSOption  Raised if the 'best_oa_location' is empty
      def parse_response(body)
        json = JSON.parse(body)

        raise(DOINotFound, json['message']) if json['error'] && json['HTTP_status_code'] == 404
        raise(SearchError, json['message']) if json['error']
        raise(NoOSOption, 'No OA option found') if json['best_oa_location'].blank?

        {
          creators: parse_authors(json['z_authors']),
          date_issued: json['published_date'],
          download_url: json['best_oa_location']['url_for_pdf'],
          journal_name: json['journal_name'],
          issn: json['journal_issns'],
          publisher: json['publisher'],
          rights_statement: parse_rights_statement(json.dig('best_oa_location', 'license')),
          title: json['title']
        }
      end

      # @param [Array<Hash<String => String>>]
      # @return [Array<String>]
      def parse_authors(authors)
        Array.wrap(authors)&.map { |a| [a['family'], a['given']].reject(&:blank?).join(', ') }
      end

      # @param [String, nil]
      # @return [String, nil]
      def parse_rights_statement(raw)
        case raw
        when 'cc-mark'
          'http://creativecommons.org/publicdomain/mark/1.0/'
        when 'cc-zero'
          'http://creativecommons.org/publicdomain/zero/1.0/'
        when /cc-by-?/
          "http://creativecommons.org/licenses/#{raw.gsub(/^cc-/, '')}/4.0/"
        end
      end
  end
end
