# frozen_string_literal: true
module Hyrax
  class AudioVisualForm < ::Spot::Forms::WorkForm
    singular_form_fields :title, :embed_url
    transforms_language_tags_for :title

    self.model_class = ::AudioVisual
    self.required_fields = [:title, :rights_statement]
    self.terms = [
      :title,
      :date,
      :embed_url,
      :rights_statement
    ].concat(hyrax_form_fields)
  end
end
