# frozen_string_literal: true
module Spot::Mappers
  class MdlPrintsMapper < BaseMapper
    self.fields_map = {
      creator: 'creator',
      date: 'date.original',
      inscription: 'description.note',
      keyword: ['keyword', 'description.series', 'relation.IsPartOf'],
      language: 'language',
      original_item_extent: 'format.extent',
      physical_medium: ['description.condition', 'format.medium'],
      publisher: 'publisher.original',
      repository_location: 'source',
      resource_type: 'resource.type'
    }

    def fields
      super + [
        :description,
        :identifier,
        :physical_medium,
        :title
      ]
    end

    # I'm fairly certain all of our descriptions are in English,
    # so we'll tag them as such.
    #
    # @return [Array<RDF::Literal>]
    def description
      metadata.fetch('description', []).map { |val| RDF::Literal(val, language: :en) }
    end

    # @return [Array<String>]
    def identifier
      islandora_url_identifiers +
        metadata.fetch('identifier.itemnumber', []).map { |id| Spot::Identifier.new('mdl', id).to_s }
    end

    # @return [Array<RDF::URI>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement'))
    end

    # @return [Array<RDF::URI,String>]
    def subject
      convert_uri_strings(metadata.fetch('subject', []))
    end

    # we'll +.fetch+ without a fallback, as a title is required
    #
    # @return [Array<RDF::Literal>]
    def title
      metadata.fetch('title').map { |val| RDF::Literal(val) }
    end
  end
end
