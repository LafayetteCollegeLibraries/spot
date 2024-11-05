# frozen_string_literal: true
# Form to edit ImageResource objects
class ImageResourceForm < ::Hyrax::Forms::ResourceForm(ImageResource)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:image_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :description, :inscription)
  include Spot::NestedAttributeFormFields(:subject, :language, :subject_ocm)

  validates_with Spot::EdtfDateValidator, fields: [:date]
end
