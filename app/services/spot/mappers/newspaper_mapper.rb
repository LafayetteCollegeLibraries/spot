# frozen_string_literal: true

module Spot::Mappers
  class NewspaperMapper < BaseHashMapper
    include NestedAttributes

    self.fields_map = {
      identifier: 'dc:identifier',
      keyword: 'dc:subject',
      physical_medium: 'dc:source',
      publisher: 'dc:publisher',
      resource_type: 'dc:type',
      rights_statement: 'dc:rights',
    }.freeze

    def fields
      super + %i[
        based_near_attributes
        date_issued
        description
        rights_statement
        title
      ]
    end

    # @return [Array<RDF::URI,String>]
    def based_near_attributes
      nested_attributes_hash_for('dc:coverage') do |place|
        case place
        when 'United States, Pennsylvania, Northampton County, Easton'
          'http://sws.geonames.org/5188140/'
        else
          Rails.logger.warn("No URI provided for #{place}; skipping")
          ''
        end
      end
    end

    # @return [Array<String>] the date in YYYY-MM-DD format
    def date_issued
      metadata['dc:date'].map do |raw_date|
        Date.parse(raw_date).strftime('%Y-%m-%d')
      end
    end

    # @return [Array<RDF::Literal>]
    def description
      metadata['dc:description'].reject(&:blank?).map do |desc|
        RDF::Literal(desc, language: :en)
      end
    end

    # @return [Array<String>]
    def rights_statement
      metadata['dc:rights'].map do |rights|
        case rights.downcase
        when 'public domain'
          'https://creativecommons.org/publicdomain/mark/1.0/'
        else
          rights
        end
      end
    end

    # @return [Array<RDF::Literal>]
    def title
      metadata['dc:title'].map { |title| RDF::Literal(title, language: :en) }
    end
  end
end
