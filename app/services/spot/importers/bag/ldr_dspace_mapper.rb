# frozen_string_literal: true
require 'uri'

module Spot::Importers
  module Bag
    class LdrDspaceMapper < ::Darlingtonia::HashMapper
      FIELDS_MAP = {
        abstract: 'description.abstract',
        creator: 'contributor.author',
        editor: 'contributor.editor',
        academic_department: 'department',
        division: 'division',
        organization: 'organization',
        keyword: 'subject',
        title: 'title',
        resource_type: 'type',
        date_issued: 'date.issued',
        date_available: 'date.available'
      }.freeze

      # Mapper#fields is what generates the hash of attributes that are passed
      # to the model's `.new` method. for the most part, the FIELDS_MAP
      # hash will work fine, but there are some cases where we'll provide our
      # own methods to this class (see: Mapper#visibility) that will do their
      # own thing and return a value instead.
      def fields
        FIELDS_MAP.keys + %i[
          bibliographic_citation
          contributor
          depositor
          description
          identifier
          language
          publisher
          source
          visibility
        ]
      end

      def bibliographic_citation
        metadata['identifier.citation'] || []
      end

      def contributor
        merge_fields 'contributor', 'contributor.other'
      end

      def date_uploaded
        Array(metadata['date.accessioned']).first
      end

      def depositor
        default_email = 'dss@lafayette.edu'
        key = 'description.provenance'
        return default_email unless metadata[key].is_a?(Array)

        submitted = metadata[key].first
        match = submitted.match(/Submitted by [^(]+ \((\w+@\w+.\w+)\)/)
        return match[1] unless match.nil?

        default_email
      end

      def description
        merge_fields 'description', 'description.sponsorship'
      end

      def identifier
        @identifier ||= gather_identifiers
      end

      def language
        Array(metadata['language.iso']).map {|lang| lang == 'en_US' ? 'en' : lang }
      end

      def publisher
        metadata['type'] == 'Book chapter' ? [] : metadata['publisher']
      end

      def source
        metadata['type'] == 'Book chapter' ? metadata['publisher'] : []
      end

      def map_field(name)
        metadata[FIELDS_MAP[name.to_sym]]
      end

      def representative_file
        @metadata[:representative_files]
      end

      # TODO: determine the visibility based on a field within the metadata
      def visibility
        ::Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end

      private

      def gather_identifiers
        ids = []

        %w[doi isbn issn].each do |type|
          key = "identifier.#{type}"
          ids << metadata[key].map { |id| "#{type}:#{id}" } if metadata[key]
        end

        ids << uris_with_handles_mapped

        ids.flatten.compact
      end

      def merge_fields(*names)
        names.map { |name| metadata[name] }.flatten.compact
      end

      def uri
        merge_fields 'identifier.uri', 'description.uri'
      end

      def uris_with_handles_mapped
        uri.map do |item|
          next item unless item =~ /hdl.handle.net/
          "hdl:#{URI.parse(item).path.sub(/^\//, '')}"
        end
      end
    end
  end
end
