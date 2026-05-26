# frozen_string_literal: true
class AudioVisualResourceForm < Hyrax::Forms::ResourceForm(AudioVisualResource)

  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:audio_visual_metadata)

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
end
