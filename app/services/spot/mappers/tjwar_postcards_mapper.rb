# frozen_string_literal: true
module Spot::Mappers
  class TjwarPostcardsMapper < BaseEaicMapper
    self.fields_map = {
      date_scope_note: 'description.indicia',
      donor: 'contributor.donor',
      keyword: ['keyword', 'relation.ispartof'],
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      repository_location: 'repository.location',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
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
  end
end
