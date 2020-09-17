# frozen_string_literal: true
module Spot::Mappers
  class LewisPostcardsMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      original_item_extent: 'format.extent',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,
        :keyword,
        :related_resource,

        # inherited methods
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
      [
        ['description.inscription.english', :en],
        ['description.inscription.japanese', :ja],
        ['description.text.english', :en],
        ['description.text.japanese', :ja]
      ].inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end

    def keyword
      merge_fields('keyword', 'relation.ispartof')
    end

    def related_resource
      merge_fields('description.citation', 'relation.seealso')
    end
  end
end
