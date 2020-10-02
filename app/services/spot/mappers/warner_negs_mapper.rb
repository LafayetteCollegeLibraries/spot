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

    # @return [Array<RDF::Literal>]
    def inscription
      [
        ['description.inscription.english', :en],
        ['description.text.english', :en],
        ['description.text.japanese', :en] # empty for most values, but has some english values that
                                           # accidentally found their way there, so we'll fix them
      ].inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end
  end
end
