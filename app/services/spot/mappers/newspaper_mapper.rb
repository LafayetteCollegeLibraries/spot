# frozen_string_literal: true

module Spot::Mappers
  class NewspaperMapper < HashMapper
    self.fields_map = {
      description: 'dc:description',
      keyword: 'dc:subject',
      publisher: 'dc:publisher',
      resource_type: 'dc:type',
      title: 'dc:title'
    }.freeze

    def fields
      super + %i[
        date_issued
      ]
    end

    # @return Array[<String>] the date in YYYY-MM-DD format
    def date_issued
      metadata['dc:date'].map do |raw_date|
        Date.parse(raw_date).strftime('%Y-%m-%d')
      end
    end
  end
end
