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
      titles_with_identifiers
    end

    # relies on LanguageTaggedTitles to gather up our usual title_alternative suspects
    # and then adds 'title.english' values that _don't_ include our identifier prefix
    #
    # @return [Array<RDF::Literal>]
    def title_alternative
      super + titles_without_identifiers
    end
  end
end
