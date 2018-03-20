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

    def self.model_attributes(_)
      super.tap do |attrs|
        attrs[:start_page] = attrs[:start_page].to_i unless attrs[:start_page].blank?
        attrs[:end_page] = attrs[:end_page].to_i unless attrs[:end_page].blank?
      end
    end
  end
end
