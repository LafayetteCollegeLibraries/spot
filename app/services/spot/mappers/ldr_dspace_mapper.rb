# frozen_string_literal: true
require 'uri'

module Spot::Mappers
  class LdrDspaceMapper < BaseHashMapper
    # Our home-grown HashMapper requires this property to return a hash
    # that defines what Publication methods (which must match the keys)
    # map to what metadata headers (which must match the value).
    #
    # @return [Hash{Symbol => String}]
    self.fields_map = {
      creator: 'contributor.author',
      editor: 'contributor.editor',
      academic_department: 'department',
      division: 'division',
      organization: 'organization',
      keyword: 'subject',
      resource_type: 'type',
      date_issued: 'date.issued',
      date_available: 'date.available'
    }.freeze

    # Mapper#fields is what generates the hash of attributes that are passed
    # to the model's `.new` method. for the most part, the FIELDS_MAP
    # hash will work fine, but there are some cases where we'll provide our
    # own methods to this class (see: Mapper#visibility) that will do their
    # own thing and return a value instead.
    #
    # @return [Array<Symbol>]
    def fields
      super + %i[
        abstract
        bibliographic_citation
        contributor
        depositor
        description
        identifier
        language
        publisher
        source
        title
        visibility
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
      merge_fields 'contributor', 'contributor.other'
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
      singularize_field('description') +
         singularize_field('description.sponsorship')
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
      Array(metadata['language.iso']).map {|lang| lang == 'en_US' ? 'en' : lang }
    end

    # If an item is a chapter (or part of a book), we're mapping the
    # value for 'publisher' to Publication#source, otherwise we'll
    # just pass on the metadata value for 'publisher'
    #
    # @return [Array<String>]
    def publisher
      if ['Part of Book', 'Book chapter'].include? metadata['type']
        []
      else
        metadata['publisher']
      end
    end

    # @return [Array<String>]
    def representative_file
      @metadata[:representative_files]
    end

    # The inverse of {#publisher}, where we're designating +source+ to
    # mean the publisher, if the item is a chapter (or part of a book).
    #
    # @return [Array<String>]
    def source
      if ['Part of Book', 'Book chapter'].include? metadata['type']
        metadata['publisher']
      else
        []
      end
    end

    # @return [Array<String>]
    def title
      singularize_field('title')
    end

    # @todo: determine the visibility based on a field within the metadata
    # @return [String]
    def visibility
      ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    private

    # Gathers identifiers for DOI, ISBN, ISSN, and Handle.net urls
    # into one place and appends a prefix.
    #
    # (see also {#uris_with_handles_mapped})
    #
    # @return [Array<String>]
    def gather_identifiers
      ids = []

      %w[doi isbn issn].each do |type|
        key = "identifier.#{type}"
        ids << metadata[key].map { |id| "#{type}:#{id}" } if metadata[key]
      end

      ids << uris_with_handles_mapped

      ids.flatten.compact
    end

    # Helper method to group the values for multiple fields into one place.
    #
    # @return [Array<String>]
    def merge_fields(*names)
      names.map { |name| metadata[name] }.flatten.compact
    end

    # Some of the fields are split on a semicolon but could actually
    # contain a value that is intended to include a semicolon. This
    # undoes that original split and returns it joined.
    #
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
        next item unless item =~ /hdl.handle.net/
        "hdl:#{URI.parse(item).path.sub(/^\//, '')}"
      end
    end
  end
end
