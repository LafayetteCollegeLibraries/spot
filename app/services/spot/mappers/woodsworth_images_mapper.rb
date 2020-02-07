# frozen_string_literal: true
module Spot::Mappers
  class WoodsworthImagesMapper < BaseEaicMapper
    self.fields_map = {
      date_scope_note: 'description.indicia',
      keyword: 'relation.ispartof',
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,
        :resource_type,

        :date,
        :date_associated,
        :description,
        :identifier,
        :location,
        :rights_statement,
        :subject,
        :title,
        :title_alternative
      ]
    end

    def inscription
      [['description.inscription.english', :en], ['description.inscription.japanese', :ja]]
        .map { |(field, tag)| field_to_tagged_literals(field, tag) }
        .flatten
        .compact
    end

    def related_resource
      merge_fields('description.citation', 'relation.seealso')
    end

    def resource_type
      metadata.fetch('resource.type', ['Image'])
    end
  end
end
