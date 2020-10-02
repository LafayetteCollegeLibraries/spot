# frozen_string_literal: true
module Spot::Mappers
  # mapper for:
  # - warner-negs-indonesia
  # - warner-negs-manchuria
  # - warner-negs-taiwan
  class WarnerNegsMapper < BaseEaicMapper
    self.fields_map = {
      keyword: ['keyword', 'relation.ispartof'],
      physical_medium: 'format.medium',
      research_assistance: 'contributor',
      subject_ocm: 'subject.ocm'
    }

    # @return [Array<Symbol>]
    def fields
      super + [
        :date,
        :date_associated,
        :description,
        :inscription,
        :location,
        :rights_statement,
        :subject,
        :title,
        :title_alternative
      ]
    end

    # For all of the collections, only the English inscription fields
    # are used, but for warner-negs-taiwan we had some English values
    # accidentally land in description.text.japanese, so we'll just map
    # them to their correct language tag.
    #
    # @return [Array<RDF::Literal>]
    def inscription
      [
        ['description.inscription.english', :en],
        ['description.text.english', :en],
        ['description.text.japanese', :en]
      ].inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end
  end
end
