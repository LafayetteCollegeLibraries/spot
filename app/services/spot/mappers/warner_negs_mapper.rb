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
      related_resource: 'relation.seealso',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    # @return [Array<Symbol>]
    def fields
      super + [
        :date,
        :date_associated,
        :description,
        :identifier,
        :inscription,
        :location,
        :rights_statement,
        :subject,
        :title,
        :title_alternative
      ]
    end

    # warner-negs-indonesia and warner-negs-manchuria use +date.image.lower+ and +date.image.upper+ for
    # their edtf ranges, but warner-negs-taiwan
    #
    # @return [Array<String>]
    def date
      edtf_ranges_for('date.image.lower', 'date.image.upper') + metadata.fetch('date.original', [])
    end

    # For all of the collections, only the English inscription fields
    # are used, but for warner-negs-taiwan we had some English values
    # accidentally land in description.text.japanese, so we'll just map
    # them to their correct language tag.
    #
    # @return [Array<RDF::Literal>]
    def inscription
      [
        ['description.inscription.english', :en],
        ['description.text.english', :en],
        ['description.text.japanese', :en]
      ].inject([]) { |pool, (field, lang)| pool + field_to_tagged_literals(field, lang) }
    end
  end
end
