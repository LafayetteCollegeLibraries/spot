# frozen_string_literal: true
#
# Metadata mapper for the Lafayette newspaper archive collection.
# See {Spot::Mappers::BaseMapper} for usage information.
require 'date'

module Spot::Mappers
  class NewspaperMapper < BaseMapper
    include NestedAttributes

    MAGIC_DATE_UPLOADED = '2010-09-16T00:00:00Z'

    self.fields_map = {
      identifier: 'dc:identifier',
      keyword: 'dc:subject',
      physical_medium: 'dc:source',
      publisher: 'dc:publisher',
      resource_type: 'dc:type',
      rights_statement: 'dc:rights'
    }.freeze

    self.default_visibility = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    # @return [Array<Symbol>]
    def fields
      super + %i[
        based_near_attributes
        date_available
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

    # @return [DateTime] The original date uploaded (when present)
    def date_uploaded
      MAGIC_DATE_UPLOADED if metadata['dc:date'].include? MAGIC_DATE_UPLOADED
    end

    # @return [Array<String>] the date in YYYY-MM-DD format
    def date_issued
      (metadata['dc:date'] - [MAGIC_DATE_UPLOADED]).map do |raw_date|
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
