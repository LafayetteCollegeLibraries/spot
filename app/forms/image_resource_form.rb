# frozen_string_literal: true
'Hyrax::Forms::ResourceForm'.safe_constantize

class ImageResourceForm < ::Hyrax::Forms::ResourceForm(ImageResource)
  include Spot::Forms::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:image_metadata)

  include Spot::Forms::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :description, :inscription)

  include Spot::Forms::ControlledVocabularyFormField(:language)
  include Spot::Forms::ControlledVocabularyFormField(:subject_ocm)

  include Spot::Forms::ControlledVocabularyFormField(:location, vocabulary_class: Spot::ControlledVocabularies::Location)
  include Spot::Forms::ControlledVocabularyFormField(:subject, vocabulary_class: Spot::ControlledVocabularies::AssignFastSubject)

  include Spot::Forms::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date]
end
