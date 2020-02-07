# frozen_string_literal: true
module Spot::Mappers
  class PaOmitsuMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      keyword: 'relation.ispartof',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'relation.seealso',
      research_assistance: 'contributor',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,

        :date,
        :date_associated,
        :description,
        :location,
        :rights_statement,
        :title,
        :title_associated
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
