# frozen_string_literal: true
module Hyrax
  class PublicationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Spot::AdditionalFormatsForController

    self.curation_concern_type = ::Publication

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PublicationPresenter
  end
end
