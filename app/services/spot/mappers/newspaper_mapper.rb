# frozen_string_literal: true

module Spot::Mappers
  class NewspaperMapper < HashMapper
    self.fields_map = {
      based_near: 'dc:coverage',
      description: 'dc:description',
      identifier: 'dc:identifier',
      keyword: 'dc:subject',
      physical_medium: 'dc:source',
      publisher: 'dc:publisher',
      resource_type: 'dc:type',
      rights_statement: 'dc:rights',
      title: 'dc:title'
    }.freeze

    def fields
      super + %i[
        based_near
        date_issued
        rights_statement
      ]
    end

    # @todo return to this
    # @return [Array<RDF::URI,String>]
    # def based_near
    #   metadata['dc:coverage'].map do |place|
    #     if place == 'United States, Pennsylvania, Northampton County, Easton'
    #       RDF::URI('http://sws.geonames.org/5188140/')
    #     else
    #       place
    #     end
    #   end
    # end

    # @return Array[<String>] the date in YYYY-MM-DD format
    def date_issued
      metadata['dc:date'].map do |raw_date|
        Date.parse(raw_date).strftime('%Y-%m-%d')
      end
    end

    # @todo return to this
    # @return Array[<RDF::URI, String>]
    # def rights_statement
    #   metadata['dc:rights'].map do |rights|
    #     case rights
    #     when 'Public domain'
    #       ::RDF::URI('https://creativecommons.org/publicdomain/mark/1.0/')
    #     else
    #       rights
    #     end
    #   end
    # end
  end
end
