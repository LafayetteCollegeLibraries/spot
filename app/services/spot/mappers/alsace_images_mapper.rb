# frozen_string_literal: true
module Spot::Mappers
  class AlsaceImagesMapper < BaseMapper
    include LanguageTaggedTitles

    self.fields_map = {
      date_scope_note: 'date.period',
      description: 'description.critical',
      language: 'language',
      physical_medium: 'physical.medium',
      resource_type: 'resource.type',
      rights_statement: 'rights.statement',
      subject_ocm: 'subject.ocm'
    }

    # @return [Array<Symbol>]
    def fields
      super + [
        :date,
        :inscription,
        :location,
        :subject,

        # these come from LanguageTaggedTitles
        :title,
        :title_alternative
      ]
    end

    # @return [Array<String>]
    def date
      merge_fields('date.postmark', 'date.image')
    end

    # From Image Remediation Plan:
    #
    #   Map from <description.text.french> AND <description.text.german> in alsace-images.
    #
    # @return [Array<RDF::Literal>]
    def inscription
      [
        %w[description.inscription.french fr], %w[description.inscription.german de],
        %w[description.text.french fr], %w[description.text.german de]
      ].collect { |(key, language)| field_to_tagged_literals(key, language) }.flatten
    end

    # @return [Array<RDF::URI, String>]
    def location
      raw_values = merge_fields('coverage.location.image', 'coverage.location.postmark',
                                'coverage.location.producer', 'coverage.location.recipient',
                                'coverage.location.sender')

      convert_uri_strings(raw_values)
    end

    # @return [Array<RDF::URI, String>]
    def subject
      convert_uri_strings(metadata['subject'])
    end
  end
end
