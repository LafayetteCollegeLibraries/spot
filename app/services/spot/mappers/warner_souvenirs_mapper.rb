# frozen_string_literal: true
module Spot::Mappers
  class WarnerSouvenirsMapper < BaseEaicMapper
    self.fields_map = {
      date_scope_note: 'description.indicia',
      keyword: 'relation.ispartof',
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      subject_ocm: 'subject.ocm'
    }

    # @return [Array<Symbol>]
    def fields
      super + [
        :date_associated,
        :location,
        :rights_statement,

        # from LanguageTaggedLiterals mixin
        :date,
        :description,
        :identifier,
        :subject,
        :title,
        :title_alternative
      ]
    end

    # @return [Array<String>]
    def date_associated
      edtf_ranges_for('date.image.lower', 'date.image.upper')
    end

    # @return [Array<RDF::URI>]
    def location
      convert_uri_strings(merge_fields('coverage.location', 'coverage.location.country'))
    end

    # @return [Array<RDF::URI>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end
  end
end
