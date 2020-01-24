# frozen_string_literal: true
module Spot::Mappers
  class WarnerSouvenirsMapper < BaseEaicMapper
    self.fields_map = {
      date_scope_note: 'description.indicia',
      language: 'language',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      subject_ocm: 'subject.ocm'
    }

    # @return [Array<Symbol>]
    def fields
      super + [
        :date,
        :date_associated,
        :description,
        :identifier,
        :location,
        :rights_statement,
        :subject,

        # from LanguageTaggedLiterals mixin
        :title,
        :title_alternative
      ]
    end

    # @return [Array<String>]
    def date
      edtf_ranges_for('date.artifact.lower', 'date.artifact.upper')
    end

    # @return [Array<String>]
    def date_associated
      edtf_ranges_for('date.image.lower', 'date.image.upper')
    end

    # @return [Array<RDF::Literal>]
    def description
      field_to_tagged_literals('description.critical', :en)
    end

    # @return [Array<RDF::URI>]
    def location
      convert_uri_strings(merge_fields('coverage.location', 'coverage.location.country'))
    end

    # @return [Array<RDF::URI>]
    def rights_statement
      convert_uri_strings(metadata.fetch('rights.statement', []))
    end

    # @return [Array<RDF::URI>]
    def subject
      convert_uri_strings(metadata.fetch('subject', []))
    end
  end
end
