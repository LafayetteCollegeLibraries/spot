# frozen_string_literal: true
module Hyrax
  class ImageForm < ::Spot::Forms::WorkForm
    transforms_language_tags_for :title, :title_alternative, :subtitle, :description, :inscription
    transforms_nested_fields_for :subject_ocm, :language
    singular_form_fields :title

    self.model_class = ::Image
    self.required_fields = [:title, :resource_type, :rights_statement]
    self.terms = [
      :title,
      :resource_type,
      :rights_statement,

      # non-required fields
      :date,
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
    ].concat(hyrax_form_fields)

    class << self
      def build_permitted_params
        super.tap do |params|
          params << { location_attributes: [:id, :_destroy] }
          params << { subject_attributes: [:id, :_destroy] }
        end
      end
    end
  end
end
