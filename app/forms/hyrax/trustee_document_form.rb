# Generated via
#  `rails generate hyrax:work TrusteeDocument`
module Hyrax
  class TrusteeDocumentForm < Hyrax::Forms::WorkForm
    self.model_class = ::TrusteeDocument
    self.terms = [
      :title,
      :start_page,
      :end_page,
    ]
  end
end
