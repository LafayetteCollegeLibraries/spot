# frozen_string_literal: true
class ImageResourceForm < ::Hyrax::Forms::ResourceForm(ImageResource)
  include Spot::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:image_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :description, :inscription)

  include Spot::ControlledVocabularyFormField(:language)
  include Spot::ControlledVocabularyFormField(:subject_ocm)

  include Spot::ControlledVocabularyFormField(:location, vocabulary_class: Spot::ControlledVocabularies::Location)
  include Spot::ControlledVocabularyFormField(:subject, vocabulary_class: Spot::ControlledVocabularies::AssignFastSubject)

  include Spot::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date]
end
