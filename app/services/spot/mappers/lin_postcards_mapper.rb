# frozen_string_literal: true
module Spot::Mappers
  class LinPostcardsMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      keyword: ['keyword', 'relation.ispartof'],
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'description.citation',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :date_associated,
        :description,
        :identifier,
        :inscription,
        :location,
        :rights_statement,
        :subject,
        :title,
        :title_alternative
      ]
    end

    # @return [Array<RDF::Literal>]
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
