# Generated via
#  `rails generate hyrax:work TrusteeDocument`
module Hyrax
  class TrusteeDocumentForm < Hyrax::Forms::WorkForm
    self.model_class = ::TrusteeDocument

    self.required_fields = [
      :title,
      :date_created,
      :classification
    ]

    self.terms = [
      :title,
      :date_created,
      :start_page,
      :end_page,
      :classification
    ]
  end
end
