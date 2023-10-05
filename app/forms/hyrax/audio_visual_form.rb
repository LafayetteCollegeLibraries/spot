module Hyrax
  class AudioVisualForm < ::Spot::Forms::WorkForm
    singular_form_fields :title
    transforms_language_tags_for :title

    self.model_class = ::AudioVisual
    self.required_fields = [:title, :rights_statement]
    self.terms = [
      :title,
      :date,
      :embed_url,
      :rights_statement,
    ]
  end
end