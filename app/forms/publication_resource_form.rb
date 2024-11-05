# frozen_string_literal: true
# Form to edit PublicationResource objects
class PublicationResourceForm < ::Hyrax::Forms::ResourceForm(PublicationResource)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:institutional_metadata)
  include Hyrax::FormFields(:publication_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :abstract, :description)
  include Spot::NestedAttributeFormFields(:subject, :language, :academic_department, :division)

  validates_with Spot::EdtfDateValidator, fields: [:date_issued]
end
