# Generated via
#  `rails generate hyrax:work Trustee::Document`

module Hyrax
  class Trustee::DocumentsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Trustee::Document

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::Trustee::DocumentPresenter
  end
end
