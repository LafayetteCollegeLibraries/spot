# frozen_string_literal: true
module Hyrax
  class ImageForm < ::Spot::Forms::WorkForm
    transforms_language_tags_for :title, :title_alternative, :subtitle, :description, :inscription
    transforms_nested_fields_for :subject_ocm

    self.model_class = ::Image
    self.required_fields = [:title, :resource_type, :date, :rights_statement]
    self.terms = [
      :title,
      :resource_type,
      :date,
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
      :subject_ocm,
      :ethnic_group,
      :note
    ].concat(hyrax_form_fields)
  end
end
