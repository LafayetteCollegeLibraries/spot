# frozen_string_literal: true
module Hyrax
  class AudioVisualForm < ::Spot::Forms::WorkForm
    transforms_language_tags_for :title, :title_alternative, :subtitle, :description, :inscription
    singular_form_fields :title, :format

    self.model_class = ::AudioVisual
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
      :research_assistance,
      :related_resource,
      :local_identifier,
      :note,
      :provenance,
      :barcode,
      :premade_derivatives
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
