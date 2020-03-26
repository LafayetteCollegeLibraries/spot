# frozen_string_literal: true
module Spot::Mappers
  class CapMapper < BaseMapper
    include LanguageTaggedTitles

    self.primary_title_map = { 'english' => :en }
    self.fields_map = {
      creator: 'creator.photographer',
      date: 'date.range',
      keyword: 'keyword',
      original_item_extent: 'format.size',
      physical_medium: 'format.medium',
      resource_type: 'resource.type'
    }

    def fields
      super + [
        :description,
        :subject,

        # included with LanguageTaggedTitles mixin
        :title
      ]
    end

    # @return [Array<RDF::Literal>]
    def description
      field_to_tagged_literals('description.critical', :en)
    end

    # Grabs and convert values in 'rights.digital' to RDF::URI objects
    # (where applicable). Non-URIs are retained as strings.
    #
    # @return [Array<RDF::URI, String>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.digital', []))
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
