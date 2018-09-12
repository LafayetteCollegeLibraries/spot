# frozen_string_literal: true

module Spot::Mappers
  class NewspaperMapper < ::Darlingtonia::HashMapper
    FIELDS_MAP = {
      description: 'dc:description',
      keyword: 'dc:subject',
      publisher: 'dc:publisher',
      resource_type: 'dc:type',
      title: 'dc:title'
    }.freeze

    def fields
      FIELDS_MAP.keys + %i[
        date_issued
      ]
    end

    # @return Array[<String>] the date in YYYY-MM-DD format
    def date_issued
      metadata['dc:date'].map do |raw_date|
        Date.parse(raw_date).strftime('%Y-%m-%d')
      end
    end

    # @todo Move to a concern/mixin
    # @param [String] name The field name
    # @return [any]
    def map_field(name)
      metadata[FIELDS_MAP[name.to_sym]]
    end
  end
end
