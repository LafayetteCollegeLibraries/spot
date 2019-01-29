# frozen_string_literal: true
require 'uri'

# Metadata mapper for items in the existing Lafayette Digital Repository (DSpace).
# See {Spot::Mappers::BaseMapper} for usage information.
module Spot::Mappers
  class LdrDspaceMapper < BaseMapper
    # Our home-grown HashMapper requires this property to return a hash
    # that defines what Publication methods (which must match the keys)
    # map to what metadata headers (which must match the value).
    #
    # @return [Hash{Symbol => String}]
    self.fields_map = {
      academic_department: 'department',
      creator: 'contributor.author',
      date_available: 'date.available',
      division: 'division',
      editor: 'contributor.editor',
      keyword: 'subject',
      organization: 'organization',
      resource_type: 'type',
      rights_statement: 'dc:rights'
    }.freeze

    self.default_visibility = ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    # @return [Array<Symbol>]
    def fields
      super + %i[
        abstract
        bibliographic_citation
        contributor
        date_issued
        depositor
        description
        identifier
        language
        publisher
        source
        title
      ]
    end

    # We've found that, in pretty much all cases, abstracts are likely
    # to contain semicolons as part of their content, rather than to
    # suggest multiple abstracts. As a business rule, we've limited these
    # to 0/1 per publication, so we'll need to join them together.
    # This returns an array because we're leaving most ActiveFedora model
    # properties as +multiple: true+
    #
    # @return [Array<String>]
    def abstract
      singularize_field('description.abstract')
    end

    # @return [Array<String>]
    def bibliographic_citation
      singularize_field('identifier.citation')
    end

    # @return [Array<String>]
    def contributor
      merge_fields('contributor', 'contributor.other')
    end

    # @return [Array<String>]
    def date_issued
      metadata['date.issued'].map { |d| d.gsub(/T\d{2}:\d{2}:\d{2}Z$/, '') }
    end

    # @return [String]
    def date_uploaded
      Array(metadata['date.accessioned']).first
    end

    # @return [String]
    def depositor
      default_email = 'dss@lafayette.edu'
      key = 'description.provenance'
      return default_email unless metadata[key].is_a?(Array)

      submitted = metadata[key].first
      match = submitted.match(/Submitted by [^(]+ \((\w+@\w+.\w+)\)/)
      return match[1] unless match.nil?

      default_email
    end

    # @return [Array<String>]
    def description
      singularize_field('description') + singularize_field('description.sponsorship')
    end

    # Values for doi, issn, isbn, and handle.net urls, mapped to have
    # a prefix added (and handle.net hostname stripped out).
    #
    # see {#gather_identifiers}
    #
    # @return [Array<String>]
    def identifier
      @identifier ||= gather_identifiers
    end

    # @return [Array<String>]
    def language
      metadata['language.iso'].map { |lang| lang == 'en_US' ? 'en' : lang }
    end

    # If an item is a chapter (or part of a book), we're mapping the
    # value for 'publisher' to Publication#source, otherwise we'll
    # just pass on the metadata value for 'publisher'
    #
    # @return [Array<String>]
    def publisher
      chapter_or_book? ? [] : metadata['publisher']
    end

    # The inverse of {#publisher}, where we're designating +source+ to
    # mean the publisher, if the item is a chapter (or part of a book).
    #
    # @return [Array<String>]
    def source
      chapter_or_book? ? metadata['publisher'] : []
    end

    # LDR titles are appended with `_<en>` (or whatever 2-letter language code
    # necessary), so we'll strip those out and use them in the RDF::Literal we return.
    #
    # @return [Array<RDF::Literal>]
    def title
      singularize_field('title').map do |title|
        next RDF::Literal.new(title) unless (m = title.match(/_<(\w\w)>$/))
        RDF::Literal.new(title.gsub(m[0], ''), language: m[1].to_sym)
      end
    end

    private

      # Is this work a chapter/part-of-book?
      #
      # @return [true, false]
      def chapter_or_book?
        ['Book chapter', 'Part of Book'].include? metadata['type']
      end

      # Gathers identifiers for DOI, ISBN, ISSN, and Handle.net urls
      # into one place and appends a prefix.
      #
      # (see also {#uris_with_handles_mapped})
      #
      # @return [Array<String>]
      def gather_identifiers
        [].tap do |ids|
          %w[doi isbn issn].each do |type|
            key = "identifier.#{type}"
            ids << metadata[key].map { |id| "#{type}:#{id}" } if metadata[key]
          end

          ids << uris_with_handles_mapped
        end.flatten.compact
      end

      # Helper method to group the values for multiple fields into one place.
      #
      # @param [Array<String>] *names field names to merge
      # @return [Array<String>]
      def merge_fields(*names)
        names.map { |name| metadata[name] }.flatten.compact
      end

      # Some of the fields are split on a semicolon but could actually
      # contain a value that is intended to include a semicolon. This
      # undoes that original split and returns it joined.
      #
      # @param [String] field
      # @return [Array<String>]
      def singularize_field(field)
        return [] unless metadata[field].present?
        Array(metadata[field].join(';'))
      end

      # +identifier.uri+ and +description.uri+ fields combined and handle.net
      # uris are transformed into the path with a +hdl+ prefix
      # (eg. +hdl:123/456+)
      #
      # @return [Array<String>]
      def uris_with_handles_mapped
        merge_fields('identifier.uri', 'description.uri').map do |item|
          next item unless item.match?(/hdl.handle.net/)
          "hdl:#{URI.parse(item).path.sub(/^\//, '')}"
        end
      end
  end
end
