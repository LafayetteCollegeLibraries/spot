# frozen_string_literal: true
module Spot
  class DOINotFound < StandardError; end

  class UnpaywallSearchService
    include Singleton

    API_BASE_URL = 'https://api.unpaywall.org'

    class_attribute :email_address
    self.email_address = 'dss@lafayette.edu'

    def self.find(doi)
      instance.find(doi)
    end

    def find(doi)
      response = connection.get("/v2/#{doi}")
      parsed = JSON.parse(response.body)

      raise DOINotFound, parsed['message'] if parsed['error']

      parsed
    end

    private

      # @return [Faraday::Connection]
      def connection
        @connection ||= Faraday.new(url: API_BASE_URL, params: { email: email_address })
      end
  end
end
