# frozen_string_literal: true
# Form to edit AudioVisualResource objects
"Spot::LanguageTaggedFormFields".constantize
"Spot::ControlledVocabularyFormField".constantize
"Spot::IdentifierFormFields".constantize
class AudioVisualResourceForm < ::Hyrax::Forms::ResourceForm(AudioVisualResource)
  include Spot::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:audio_visual_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :description, :inscription)
  include Spot::ControlledVocabularyFormField(:language)
  include Spot::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date]
end
