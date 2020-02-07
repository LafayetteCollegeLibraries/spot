# frozen_string_literal: true
module Spot::Mappers
  class LewisPostcardsMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      keyword: 'relation.ispartof',
      original_item_extent: 'format.extant',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'relation.seealso',
      research_assistance: 'contributor',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,

        # inherited methods
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
  end
end
