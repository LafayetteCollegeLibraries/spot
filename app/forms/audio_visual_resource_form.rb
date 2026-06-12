# frozen_string_literal: true
class AudioVisualResourceForm < Hyrax::Forms::ResourceForm(AudioVisualResource)
  include Spot::Forms::BaseResourceFormBehavior

  include Hyrax::FormFields(:audio_visual_metadata)

  language_tagged_field(:inscription)

  def primary_terms # rubocop:disable Metrics/MethodLength
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
end
