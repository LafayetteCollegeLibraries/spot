# frozen_string_literal: true
module Spot::Mappers
  class WarnerSlidesMapper < BaseEaicMapper
    self.fields_map = {
      keyword: 'relation.ispartof',
      original_item_extent: 'format.extent',
      physical_medium: 'format.medium',
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
        :title
      ]
    end

    def date
      metadata.fetch('date.original', [])
    end

    def inscription
      field_to_tagged_literals('description.text.english', :en)
    end
  end
end
