# frozen_string_literal: true
module Spot
  # Service wrapper for interacting with Lafayette's Web Data Services API endpoint.
  # Endpoint methods are added as needed. Currently supports:
  #   - getInstructors (see {#instructors})
  #   - getPerson (see {#person})
  #   - getTermInfo (see {#term})
  #
  # @see https://webdataservices.lafayette.edu
  class LafayetteWdsService
    class SearchError < StandardError; end

    # Helper class method wrapper around #instructors
    # @see {#instructors}
    def self.instructors(api_key:, term:)
      new(api_key: api_key).instructors(term: term)
    end

    # Helper class method wrapper around #person
    # @see {#person}
    def self.person(api_key:, username: nil, email: nil, lnumber: nil)
      new(api_key: api_key).person(username: username, email: email, lnumber: lnumber)
    end

    # Helper class method wrapper around #term
    # @see {#term}
    def self.term(api_key:, code: nil, year: nil)
      new(api_key: api_key).term(code: code, year: year)
    end

    # @params [Hash] options
    # @option [String] api_key
    def initialize(api_key:)
      @api_key = api_key
    end

    # Per WDS API documentation: "Returns a list of instructors teaching at least one course in the given term."
    #
    # @params [Hash] options
    # @option [String] term
    #   Code for the term to query against. Ex. `"202103"`
    # @return [Array<Hash<String => String>>]
    def instructors(term:)
      fetch_and_parse('/instructors', term: term)
    end

    # Searches the Directory for a user based on their username, email, or
    # L-number. Calling without parameters will return a list of all Directory
    # users. When multiple results are found, an Array is returned, when
    # a single result is found, that Hash is returned. When no matching
    # users are found, this returns `false`.
    #
    # @params [Hash] options
    # @option [String] username
    #   A user's netid (ex. `"malantoa"`)
    # @option [String] email
    #   A user's email address (ex. `"malantoa@lafayette.edu")
    # @option [String] lnumber
    #   A user's L-number (ex. `"L00000000"`)
    # @return [Array<Hash<String => String>>, Hash<String => String>, false]
    def person(username: nil, email: nil, lnumber: nil)
      params = { lnumber: lnumber, email: email, username: username }.compact

      fetch_and_parse('/person', params)
    end

    # Queries WDS for information about a term by providing a termcode
    # or an encompassing year.
    #
    # @params [Hash] options
    # @option [String] code
    #   Termcode to search for
    # @option [String] year
    #   Year to search for
    # @return [Hash<String => String>, false]
    # @todo Currently untested
    def term(code: nil, year: nil)
      params = { term: code, year: year }.compact

      fetch_and_parse('/termInfo', params)
    end

    # prevent our api_key from leaking
    #
    # @return [String]
    def inspect
      "#<#{self.class.name}:#{object_id}>"
    end

    private

      attr_reader :api_key

      # Faraday connection we'll use for making requests
      def client
        @client ||= Faraday::Connection.new(url: web_data_services_url, headers: client_headers)
      end

      def client_headers
        {
          'Accept' => 'application/json',
          'apikey' => api_key,
          'User-Agent' => 'Lafayette Digital Repository // https://github.com/LafayetteCollegeLibraries/spot'
        }
      end

      def fetch_and_parse(path, params)
        response = client.get(path, params)
        parsed = JSON.parse(response.body)

        return parsed if response.status == 200

        msg = parsed.fetch('message', 'An unknown error occurred')
        raise(SearchError, msg)
      end

      def web_data_services_url
        ENV.fetch('LAFAYETTE_WDS_URL')
      end
  end
end
