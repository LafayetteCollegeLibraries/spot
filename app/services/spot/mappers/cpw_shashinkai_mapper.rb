# frozen_string_literal: true
module Spot::Mappers
  # @todo resource_type?
  class CpwShashinkaiMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      keyword: 'relation.ispartof',
      original_item_extent: 'format.extant',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      research_assistance: 'contributor',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
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
        .select { |v| has_identifier_prefix?(v) }
        .map { |v| RDF::Literal(v, language: :en) }
    end

    # relies on LanguageTaggedTitles to gather up our usual title_alternative suspects
    # and then adds 'title.english' values that _don't_ include our identifier prefix
    #
    # @return [Array<RDF::Literal>]
    def title_alternative
      super + metadata['title.english']
                .reject { |v| has_identifier_prefix?(v) }
                .map { |v| RDF::Literal(v, language: :en) }
    end

    private

      # Does a value look like "[aa0001] title" ?
      #
      # @return bool
      def has_identifier_prefix?(value)
        value.match?(/^\[[^\]]+\])
      end
  end
end
