# frozen_string_literal: true
module Spot::Mappers
  class PacwarPostcardsMapper < BaseEaicMapper
    self.fields_map = {
      creator: 'creator.maker',
      date_scope_note: 'description.indicia',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'description.citation',
      research_assistance: 'contributor',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :inscription,
        :location,
        :rights_statement,

        # field methods provided by the BaseEaicMapper
        :date,
        :description,
        :identifier,
        :subject,
        :title,
        :title_alternative
      ]
    end

    def date_associated
      edtf_ranges_for('date.image.lower', 'date.image.upper')
    end

    def inscription
      [
        ['description.inscription.english', :en],
        ['description.inscription.japanese', :ja],
        ['description.text.english', :en],
        ['description.text.japanese', :ja]
      ].inject([]) { |pool, (field, language)| pool + field_to_tagged_literals(field, language) }
    end
  end
end
