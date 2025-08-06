# frozen_string_literal: true
#
# Form to edit AudioVisualResource objects
class AudioVisualResourceForm < ::Hyrax::Forms::ResourceForm(AudioVisualResource)
  include Spot::Forms::ResourceFormBehavior

  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:audio_visual_metadata)

  include Spot::Forms::LanguageTaggedFormFields.for(:title, :title_alternative, :subtitle, :description, :inscription)
  include Spot::Forms::ControlledVocabularyFormField.for(:language)
  include Spot::Forms::IdentifierFormFields

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
