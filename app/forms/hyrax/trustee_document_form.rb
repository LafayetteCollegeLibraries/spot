# Generated via
#  `rails generate hyrax:work TrusteeDocument`
module Hyrax
  class TrusteeDocumentForm < Hyrax::Forms::WorkForm
    self.model_class = ::TrusteeDocument

    self.required_fields = [
      :title,
      :date_created,
      :source
    ]

    self.terms = [
      :title,
      :date_created,
      :page_start,
      :page_end,
      :source
    ]

    def self.model_attributes(_)
      super.tap do |attrs|
        attrs[:page_start] = attrs[:page_start].to_i unless attrs[:page_start].blank?
        attrs[:page_end] = attrs[:page_end].to_i unless attrs[:page_end].blank?
      end
    end
  end
end
