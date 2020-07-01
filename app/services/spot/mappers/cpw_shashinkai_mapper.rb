# frozen_string_literal: true
module Spot::Mappers
  # @todo resource_type?
  class CpwShashinkaiMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      original_item_extent: 'format.extent',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :keyword,
        :inscription,
        :related_resource,

        :date,
        :description,
        :identifier,
        :location,
        :rights_statement,
        :subject,
        :title,
        :title_alternative
      ]
    end

    def keyword
      merge_fields('keyword', 'relation.ispartof')
    end

    def inscription
      [
        ['description.inscription.english', :en],
        ['description.inscription.japanese', :ja],
        ['description.text.english', :en],
        ['description.text.japanese', :ja]
      ].inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end

    def related_resource
      merge_fields('description.citation', 'relation.seealso')
    end

    # only selects titles that begin with our identifer prefix
    #
    # @return [Array<RDF::Literal>]
    def title
      metadata['title.english']
        .select { |v| identifier_prefix?(v) }
        .map { |v| RDF::Literal(v, language: :en) }
    end

    # relies on LanguageTaggedTitles to gather up our usual title_alternative suspects
    # and then adds 'title.english' values that _don't_ include our identifier prefix
    #
    # @return [Array<RDF::Literal>]
    def title_alternative
      super + metadata['title.english'].reject { |v| identifier_prefix?(v) }.map { |v| RDF::Literal(v, language: :en) }
    end

    private

      # Does a value look like "[aa0001] title" ?
      #
      # @return bool
      def identifier_prefix?(value)
        value.match?(/^\[\w{2}\d{4}\]/)
      end
  end
end
