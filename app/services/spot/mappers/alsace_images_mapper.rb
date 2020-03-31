# frozen_string_literal: true
module Spot::Mappers
  class AlsaceImagesMapper < BaseMapper
    # note: we're not using the public #title or #title_alternative methods
    # but we are using the #field_to_tagged_literals helper
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
        :identifier,
        :inscription,
        :location,
        :subject,
        :title,
        :title_alternative
      ]
    end

    # @return [Array<String>]
    def date
      merge_fields('date.postmark', 'date.image')
    end

    # @return [Array<String>]
    def identifier
      islandora_url_identifiers
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

    # Since we don't have English titles for these, we'll prioritize (in order):
    # - French title
    # - German title
    # - 'Untitled'
    #
    # @return [Array<RDF::Literal>]
    def title
      return field_to_tagged_literals('title.french', :fr) unless metadata['title.french'].blank?
      return field_to_tagged_literals('title.german', :de) unless metadata['title.german'].blank?

      [RDF::Literal('[Untitled]', language: :en)]
    end

    # We'll only have an alternative title if both French and German titles are available.
    # Then we'll use the German title(s) as alternative(s).
    #
    # @return [Array<RDF::Literal>, nil]
    def title_alternative
      return [] unless metadata['title.french'].present? && metadata['title.german'].present?

      field_to_tagged_literals('title.german', :de)
    end
  end
end
