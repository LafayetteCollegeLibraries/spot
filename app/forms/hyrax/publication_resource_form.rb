# frozen_string_literal: true
module Hyrax
  # Form to edit PublicationResource objects
  class PublicationResourceForm < ::Hyrax::Forms::ResourceForm(PublicationResource)
    include Hyrax::FormFields(:base_metadata)
    include Hyrax::FormFields(:institutional_metadata)
    include Hyrax::FormFields(:publication_metadata)

    include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :abstract, :description)
    include Spot::AttributeFormFields(:subject, :language, :academic_department, :division)

    # property :subject_attributes, virtual: true, populator: :subject_populator

    validates_with Spot::EdtfDateValidator, fields: [:date_issued]
  end
end