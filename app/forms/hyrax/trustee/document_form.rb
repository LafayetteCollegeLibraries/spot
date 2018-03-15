# Generated via
#  `rails generate hyrax:work Trustee::Document`
module Hyrax
  class Trustee::DocumentForm < Hyrax::Forms::WorkForm
    self.model_class = ::Trustee::Document
    self.terms += [:resource_type]
  end
end
