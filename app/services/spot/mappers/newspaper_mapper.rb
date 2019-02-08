# frozen_string_literal: true
#
# Metadata mapper for the Lafayette newspaper archive collection.
# See {Spot::Mappers::BaseMapper} for usage information.
require 'date'

module Spot::Mappers
  class NewspaperMapper < BaseMapper
    include NestedAttributes

    self.fields_map = {
      identifier: 'dc:identifier',
      keyword: 'dc:subject',
      physical_medium: 'dc:source',
      publisher: 'dc:publisher',
      rights_statement: 'dc:rights'
    }.freeze

    self.default_visibility = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    # @return [Array<Symbol>]
    def fields
      super + %i[
        date_available
        date_issued
        description
        place_attributes
        resource_type
        rights_statement
        title
      ]
    end

    # Some of our Newspaper dc:date values include multiple values.
    # We've set a business rule that the newest of those dates is
    # the date in which the item was uploaded to the original repository.
    #
    # @return [String] The original date uploaded (when present)
    def date_uploaded
      return if clean_dates.size <= 1
      clean_dates.last
    end

    # See {#date_uploaded} for details. All but the newest of
    # our dc:date values, mapped to YYYY-MM-DD format
    #
    # @return [Array<String>]
    def date_issued
      clean_dates[0...-1].map { |raw| Date.parse(raw).strftime('%Y-%m-%d') }
    end

    # @return [Array<RDF::Literal>]
    def description
      metadata['dc:description'].reject(&:blank?).map do |desc|
        RDF::Literal(desc, language: :en)
      end
    end

    # @return [Array<RDF::URI,String>]
    def place_attributes
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

    # @return [Array<String>]
    def resource_type
      ['Periodical']
    end

    # @return [Array<RDF::Literal>]
    def title
      metadata['dc:title'].map { |title| RDF::Literal(title, language: :en) }
    end

    private

      # Cleans up the dc:date value, which sometimes contains duplicate
      # values, or unordered ones, and caches it in an instance variable.
      #
      # @return [Array<String>]
      def clean_dates
        @clean_dates ||= metadata['dc:date'].uniq.sort
      end
  end
end
