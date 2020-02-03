# frozen_string_literal: true
module Spot::Mappers
  # @todo no `date` field exists to pull updated date_uploaded value from?
  # @todo format.extant values have pipes in the metadata, is this supposed to be split?
  # or is that how the metadata is expected to be formatted?
  class CpwNofukoMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      keyword: 'relation.ispartof',
      original_item_extent: 'format.extant',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,
        :location,
        :related_resource,
        :rights_statement,

        :date,
        :description,
        :identifier,
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

    def related_resource
      merge_fields('description.citation', 'relation.seealso')
    end
  end
end
