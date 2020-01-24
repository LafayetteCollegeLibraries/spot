# frozen_string_literal: true
module Spot::Mappers
  class RjwStereoMapper < BaseEaicMapper
    self.fields_map = {
      physical_medium: 'format.medium',
      publisher: 'creator.company',
      subject_ocm: 'subject.ocm'
    }

    def fields
      super + [
        :date,
        :date_associated,
        :description,
        :identifier,
        :location,
        :subject,
        :title,
        :title_alternative
      ]
    end

    def date_associated
      edtf_ranges_for('date.image.lower', 'date.image.upper')
    end
  end
end
