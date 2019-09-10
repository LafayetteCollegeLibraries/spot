# frozen_string_literal: true
module Hyrax
  # Generated form for Image
  class ImageForm < Hyrax::Forms::WorkForm
    include ::IdentifierFormFields
    include ::LanguageTaggedFormFields
    include ::NestedFormFields

    self.model_class = ::Image
    self.terms += [:resource_type]
  end
end
