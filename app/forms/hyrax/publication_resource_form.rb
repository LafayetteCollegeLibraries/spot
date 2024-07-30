# frozen_string_literal: true
module Hyrax
  # Form to edit PublicationResource objects
  class PublicationResourceForm < ::Hyrax::Forms::ResourceForm(PublicationResource)
    include Hyrax::FormFields(:base_metadata)
    include Hyrax::FormFields(:institutional_metadata)
    include Hyrax::FormFields(:publication_metadata)

    include Spot::Forms::LanguageTaggedFormFields(:title, :title_alternative)

    property :subject_attributes, virtual: true, populator: :subject_populator
    # validates_with Spot::EdtfDateValidator, fields: [:date_issued]

    def subject_populator(fragment:, **_options)
      adds = []
      deletes = []

      fragment.each do |_, h|
        if h['destroy'] == 'true'
          deletes << Valkyrie::ID.new(h['id'])
        else
          adds << Valkyrie::ID.new(h['id'])
        end
      end

      self.subject = ((subject + adds) - deletes).uniq
      self
    end
  end
end