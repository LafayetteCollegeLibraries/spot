# frozen_string_literal: true
module Spot::Mappers
  class MammanaPostcardsMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      donor: 'contributor.donor',
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: ['description.citation', 'relation.seealso'],
      research_assistance: 'contributor',
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
        :title,
        :title_alternative
      ]
    end

    # @return [Array<RDF:Literal>]
    def inscription
      [
        ['description.inscription.english', :en],
        ['description.inscription.japanese', :ja],
        ['description.text.english', :en],
        ['description.text.japanese', :ja]
      ].map { |(key, language)| field_to_tagged_literals(key, language) }.flatten
    end
  end
end
