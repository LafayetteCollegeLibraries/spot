# frozen_string_literal: true
class ImageResourceForm < Hyrax::Forms::ResourceForm(ImageResource)
  include Spot::Forms::BaseResourceFormBehavior

  include Hyrax::FormFields(:core_metadata)
  include Hyrax::FormFields(:base_metadata)
  include Hyrax::FormFields(:image_metadata)

  language_tagged_field(:inscription)

  def primary_terms
    [
      :title,
      :date,
      :resource_type,
      :rights_statement,

      # non-required fields
      :title_alternative,
      :subtitle,
      :date_associated,
      :date_scope_note,
      :rights_holder,
      :description,
      :inscription,
      :creator,
      :contributor,
      :publisher,
      :keyword,
      :subject,
      :location,
      :language,
      :source,
      :physical_medium,
      :original_item_extent,
      :repository_location,
      :requested_by,
      :research_assistance,
      :donor,
      :related_resource,
      :local_identifier,
      :subject_ocm,
      :note
    ]
  end
end
