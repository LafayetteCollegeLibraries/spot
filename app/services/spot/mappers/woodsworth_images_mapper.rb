# frozen_string_literal: true
module Spot::Mappers
  class WoodsworthImagesMapper < BaseEaicMapper
    self.fields_map = {
      date_scope_note: 'description.indicia',
      description: 'description.critical',
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      rights_statement: 'rights.digital',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :date,
        :date_associated,
        :inscription,
        :location,
        :resource_type,
        :title,
        :title_alternative
      ]
    end

    def date
      edtf_range_for('date.artifact.lower', 'date.artifact.upper')
    end

    def date_associated
      edtf_range_for('date.image.lower', 'date.image.upper')
    end

    def inscription
      [['description.inscription.english', :en], ['description.inscription.japanese', :ja]]
        .map { |(field, tag)| field_to_tagged_literals(field, tag) }
        .flatten
        .compact
    end

    def location
      merge_fields('coverage.location', 'coverage.location.country')
    end

    def related_resource
      merge_fields('description.citation', 'relation.seealso')
    end

    def resource_type
      metadata.fetch('resource.type', ['Image'])
    end
  end
end
