# frozen_string_literal: true
class ImageResourceForm < ::Hyrax::Forms::ResourceForm(ImageResource)
  include Spot::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:image_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :description, :inscription)
  include Spot::NestedAttributeFormFields(:subject, :language, :subject_ocm)
  include Spot::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date]
end