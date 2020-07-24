# frozen_string_literal: true
module Spot::Mappers
  class WarnerSouvenirsMapper < BaseEaicMapper
    self.fields_map = {
      date_scope_note: 'description.indicia',
      keyword: 'relation.ispartof',
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    # @return [Array<Symbol>]
    def fields
      super + [
        :location,
        :rights_statement,

        # from LanguageTaggedLiterals mixin
        :date,
        :date_associated,
        :description,
        :identifier,
        :subject,
        :title,
        :title_alternative
      ]
    end
  end
end
