# frozen_string_literal: true
module Spot::Mappers
  # @todo no `date` field exists to pull updated date_uploaded value from?
  # @todo format.extant values have pipes in the metadata, is this supposed to be split?
  # or is that how the metadata is expected to be formatted?
  class CpwNofukoMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      original_item_extent: 'format.extant',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'description.citation',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :date,
        :description,
        :identifier,
        :inscription,
        :location,
        :rights_statement,
        :subject,

        :title,
        :title_alternative
      ]
    end

    # @return [Array<String>]
    def date
      edtf_ranges_for('date.artifact.lower', 'date.artifact.upper')
    end

    def description
      field_to_tagged_literals('description.critical', :en)
    end

    def inscription
      [
        ['description.inscription.english', :en],
        ['description.inscription.japanese', :ja],
        ['description.text.english', :en],
        ['description.text.japanese', :ja]
      ].inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end

    def location
      convert_uri_strings(merge_fields('coverage.location', 'coverage.location.country'))
    end

    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end

    def subject
      convert_uri_strings(metadata.fetch('subject', []))
    end
  end
end
