# frozen_string_literal: true
module Spot::Mappers
  class PaKoshitsuMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      keyword: 'relation.ispartof',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'description.citation',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,

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
      field_to_tagged_literals('description.text.japanese', :ja)
    end
  end
end
