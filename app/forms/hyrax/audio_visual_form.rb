# frozen_string_literal: true
module Hyrax
  class AudioVisualForm < ::Spot::Forms::WorkForm
    singular_form_fields :title
    transforms_language_tags_for :title

    self.model_class = ::AudioVisual
    self.required_fields = [:title, :rights_statement]
    self.terms = [
      :title,
      :date,
      :rights_statement,
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
