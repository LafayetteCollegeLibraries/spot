# frozen_string_literal: true
#
# @note We're following Hyrax conventions by using the form `MixinName(params)`, which the
#       autoloader doesn't seem to like, raising NoMethodErrors; probably because this class
#       comes alphabetically before Hyrax and Spot and those constants haven't yet loaded.
#       By calling :safe_constantize on them first, they'll be available when setting up the class.
#
# @todo is there some configuration we're missing that was added to Hyrax to account for this?
#
'Hyrax::Forms::ResourceForm'.safe_constantize
'Spot::LanguageTaggedFormFields'.safe_constantize
'Spot::ControlledVocabularyFormField'.safe_constantize
'Spot::IdentifierFormFields'.safe_constantize
'Spot::EdtfDateValidator'.safe_constantize

# Form to edit AudioVisualResource objects
class AudioVisualResourceForm < ::Hyrax::Forms::ResourceForm(AudioVisualResource)
  include Spot::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:audio_visual_metadata)

  include Spot::LanguageTaggedFormFields(:title, :title_alternative, :subtitle, :description, :inscription)
  include Spot::ControlledVocabularyFormField(:language)
  include Spot::IdentifierFormFields

  validates_with Spot::EdtfDateValidator, fields: [:date]

  # rubocop:disable Metrics/MethodLength
  def primary_terms
    [
      # required_fields first
      :title,
      :date,
      :resource_type,
      :rights_statement,

      # non-required fields
      :rights_holder,
      :subtitle,
      :title_alternative,
      :date_associated,
      :creator,
      :contributor,
      :publisher,
      :source,
      :standard_identifier,
      :local_identifier,
      :description,
      :inscription,
      :subject,
      :keyword,
      :language,
      :physical_medium,
      :original_item_extent,
      :location,
      :repository_location,
      :note,
      :related_resource,
      :research_assistance,
      :provenance,
      :barcode
    ]
  end
  # rubocop:enable Metrics/MethodLength
end
