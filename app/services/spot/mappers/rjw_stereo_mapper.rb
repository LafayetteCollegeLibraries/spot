# frozen_string_literal: true
module Spot::Mappers
  class RjwStereoMapper < BaseEaicMapper
    self.fields_map = {
      keyword: 'relation.ispartof',
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      related_resource: 'relation.seealso',
      research_assistance: 'contributor',
      resource_type: 'resource.type',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :description,

        # BaseEaicMapper fields
        :date,
        :date_associated,
        :identifier,
        :location,
        :rights_statement,
        :subject,
        :title,
        :title_alternative
      ]
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
