# frozen_string_literal: true
module Spot::Mappers
  class GeologySlidesEsiMapper < BaseEaicMapper
    self.primary_title_map = { 'title' => :en }

    self.fields_map = {
      keyword: ['keyword', 'relation.ispartof'],
      related_resource: ['relation.seealso.book', 'relation.seealso.image']
    }

    def fields
      super + [
        :date,
        :description,
        :identifier,
        :location,
        :rights_statement,
        :subject,
        :subtitle,

        :title
      ]
    end

    # this is a bad code smell, but since we're inheriting from
    # {BaseEaicMapper}, we need to replace the #date method here,
    # rather than use the +fields_map+ property. since {BaseEaicMapper#date}
    # exists, we'll never get to the +fields_map+.
    #
    # @return [Array<String>]
    def date
      metadata.fetch('date.original', [])
    end

    # @return [Array<RDF::Literal>]
    def description
      ['description', 'description.vantagepoint'].map { |f| field_to_tagged_literals(f, :en) }.flatten
    end

    # @return [Array<String>]
    def identifier
      eaic_ids_from_title(field: 'title', prefix: 'geology') + islandora_url_identifiers
    end

    # @return [Array<RDF::URI>]
    def location
      convert_uri_strings(metadata.fetch('location', []))
    end

    # @return [Array<RDF::URI>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end

    # @return [Array<RDF::URI>]
    def subject
      convert_uri_strings(metadata.fetch('subject', []))
    end

    # @return [Array<RDF::Literal>]
    def subtitle
      field_to_tagged_literals('coverage.location', :en)
    end
  end
end
