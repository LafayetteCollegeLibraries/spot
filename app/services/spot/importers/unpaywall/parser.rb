# frozen_string_literal: true
#
# Importer that uses the Unpaywall API (v2) to create base records
# for new items. The records created with this should be saved to
# an administrative set that requires a review before depositing.
require 'json'

module Spot::Importers::Unpaywall
  class DOINotFound < StandardError; end

  class Parser < ::Darlingtonia::Parser
    API_BASE_URL = 'https://api.unpaywall.org'
    DEFAULT_VALIDATORS = [].freeze

    class_attribute :unpaywall_email
    self.unpaywall_email = 'dss@lafayette.edu'

    def initialize(doi:, mapper: ::Spot::Mappers::UnpaywallMapper.new)
      @doi = doi
      @mapper = mapper

      # need to copy these over from Darlingtonia::Parser in order for validation to work
      @errors = []
      @validators = self.class::DEFAULT_VALIDATORS
    end

    # @yield [Array<Darlingtonia::InputRecord>]
    # @return [Array<Darlingtonia::InputRecord>]
    def records
      input_record = [input_record_from(raw_metadata)]

      yield input_record if block_given?

      input_record
    end

  private

    # @return [Darlingtonia::InputRecord]
    def input_record_from(metadata)
      ::Darlingtonia::InputRecord.from(metadata: metadata,
                                       mapper: @mapper)
    end

    # @raise [Spot::Importers::Unpaywall::DOINotFound] when DOI not found
    # @return [Hash<String => String,Number,Boolean>]
    def raw_metadata
      response = connection.get("/v2/#{@doi}")
      parsed = JSON.parse(response.body)

      raise DOINotFound, parsed['message'] if parsed['error']

      parsed
    end

    # @return [Faraday::Connection]
    def connection
      @connection ||= Faraday.new(url: API_BASE_URL, params: { email: unpaywall_email })
    end
  end
end
