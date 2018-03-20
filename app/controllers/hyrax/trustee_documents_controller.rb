# Generated via
#  `rails generate hyrax:work TrusteeDocument`

module Hyrax
  class TrusteeDocumentsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::TrusteeDocument

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::TrusteeDocumentPresenter
  end
end
