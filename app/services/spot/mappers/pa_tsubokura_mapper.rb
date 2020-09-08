# frozen_string_literal: true
module Spot::Mappers
  class PaTsubokuraMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      keyword: 'relation.ispartof',
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,
        :related_resource,

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

    # @note: 'description.inscription.japanese' data looks like 'postmark: 38-11-23',
    #        which shouldn't be tagged 'japanese'. we'll just leave those untagged
    def inscription
      [['description.inscription.japanese', nil], ['description.text.japanese', :ja]]
        .inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end

    def related_resource
      merge_fields('description.citation', 'relation.seealso')
    end
  end
end
