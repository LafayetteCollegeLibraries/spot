# frozen_string_literal: true
module Spot::Mappers
  class GcIrohaMapper < BaseEaicMapper
    self.fields_map = {
      keyword: 'relation.ispartof',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      research_assistance: 'contributor',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,

        :date,
        :description,
        :identifier,
        :subject,
        :resource_type,
        :rights_statement,
        :title,
        :title_alternative
      ]
    end

    def inscription
      [
        ['description.inscription.japanese', :ja],
        ['description.text.japanese', :ja]
      ].inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end

    def resource_type
      ['Image']
    end
  end
end
