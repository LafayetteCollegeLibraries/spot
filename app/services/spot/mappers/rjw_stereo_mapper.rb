# frozen_string_literal: true
module Spot::Mappers
  class RjwStereoMapper < BaseEaicMapper
    self.fields_map = {
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'relation.seealso',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :date_associated,
        :description,

        # BaseEaicMapper fields
        :date,
        :identifier,
        :location,
        :rights_statement,
        :subject,
        :title,
        :title_alternative
      ]
    end

    def date_associated
      edtf_ranges_for('date.image.lower', 'date.image.upper')
    end

    # Combining values from 'description.critical' and 'description.text.english'
    # and creating tagged :en literals.
    #
    # @return [Array<RDF::Literal>]
    def description
      field_to_tagged_literals('description.critical', :en) + field_to_tagged_literals('description.text.english', :en)
    end
  end
end
