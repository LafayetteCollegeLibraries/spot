# frozen_string_literal: true
module Spot::Mappers
  class ImageMapper < BaseMapper
    # since we're expecting a CSV with headers matching our property names,
    # we'll save ourselves the hassle of writing out the key/val twice and
    # generate a Hash from an Array of properties (save for the ones that
    # require processing)
    self.fields_map = %i[
      contributor
      creator
      date
      date_associated
      date_scope_note
      description
      donor
      inscription
      language
      keyword
      note
      original_item_extent
      physical_medium
      publisher
      related_resource
      repository_location
      requested_by
      research_assistance
      resource_type
      rights_holder
      source
      subject_ocm
      subtitle
      title
      title_alternative
    ].map { |k| [k, k.to_s] }.to_h

    def fields
      super + [
        :location,
        :rights_statement,
        :subject
      ]
    end

    def location
      convert_uri_strings(metadata.fetch('location', []))
    end

    def rights_statement
      convert_uri_strings(metadata.fetch('rights_statement', []))
    end

    def subject
      convert_uri_strings(metadata.fetch('subject', []))
    end
  end
end
