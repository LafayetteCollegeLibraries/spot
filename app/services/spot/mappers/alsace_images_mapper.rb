# frozen_string_literal: true
module Spot::Mappers
  class AlsaceImagesMapper < BaseMapper
    include LanguageTaggedTitles

    self.fields_map = {}

    # @return [Array<Symbol>]
    def fields
      super + [
        :inscription,
        :resource_type,
        :location,
        :resource_type,
        :subject_ocm,

        # these come from LanguageTaggedTitles
        :title,
        :title_alternative
      ]
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

    def location
      # todo
    end

    # @return [Array<String>]
    def resource_type
      ['Image']
    end

    def subject_ocm
      # todo
    end
  end
end
