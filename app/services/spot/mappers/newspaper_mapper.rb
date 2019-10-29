# frozen_string_literal: true
#
# Metadata mapper for the Lafayette newspaper archive collection.
# See {Spot::Mappers::BaseMapper} for usage information.
require 'date'

module Spot::Mappers
  class NewspaperMapper < BaseMapper
    include NestedAttributes

    self.fields_map = {
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
        identifier
        location_attributes
        resource_type
        rights_statement
        title
      ]
    end

    # @return [Array<String>]
    def date_issued
      metadata['date_issued'].map { |raw| Date.parse(raw).strftime('%Y-%m-%d') }
    end

    # @return [String, nil]
    def date_uploaded
      metadata['date_uploaded'].present? ? metadata['date_uploaded'] : nil
    end

    # @return [Array<RDF::Literal>]
    def description
      metadata['dc:description'].reject(&:blank?).map do |desc|
        RDF::Literal(desc, language: :en)
      end
    end

    # URLs (from legacy ContentDM and current digital.lafayette.edu)
    # have an "url:" prefix appended; the other identifiers (internal
    # Fedora 3 PIDs) are given a "lafayette:" prefix.
    #
    # @return [Array<String>]
    def identifier
      return [] unless metadata['dc:identifier'] || metadata['url']

      ids = metadata.fetch('dc:identifier', []).map do |id|
        id.include?('cdm.lafayette.edu') ? "url:#{id}" : "lafayette:#{id}"
      end

      return ids unless metadata['url'].present?

      ids.push("url:#{metadata['url'].first}")
    end

    # @return [Array<RDF::URI,String>]
    def location_attributes
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
      metadata['dc:title']
        .zip(date_issued)
        .map { |(title, date)| "#{title} - #{Date.edtf(date).humanize}" }
        .map { |title| RDF::Literal(title, language: :en) }
    end
  end
end
