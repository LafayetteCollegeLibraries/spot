# frozen_string_literal: true
module Spot::Mappers
  class MckelvyHouseMapper < BaseMapper
    include LanguageTaggedTitles

    self.primary_title_map = { 'english' => :en }
    self.fields_map = {
      creator: 'creator.maker',
      date: 'date.original.search',
      original_item_extent: 'description.size',
      physical_medium: 'format.medium',
      repository_location: 'source',
      source: 'description.note'
    }

    def fields
      super + [
        :description,
        :keyword,
        :rights_statement,
        :subject,

        # from LanguageTaggedTitles
        :title
      ]
    end

    # @return [Array<RDF::Literal>]
    def description
      field_to_tagged_literals('description', :en)
    end

    # @return [Array<String>]
    def keyword
      merge_fields('keyword', 'relation.ispartof')
    end

    # Grabs and convert values in 'rights.statement' to RDF::URI objects
    # (where applicable). Non-URIs are retained as strings.
    #
    # @return [Array<RDF::URI, String>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end

    # Grabs and convert values in 'subject' to RDF::URI objects
    # (where applicable). Non-URIs are retained as strings.
    #
    # @return [Array<RDF::URI, String>]
    def subject
      convert_uri_strings(metadata.fetch('subject', []))
    end
  end
end
