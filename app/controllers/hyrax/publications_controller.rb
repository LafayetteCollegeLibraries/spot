# frozen_string_literal: true
module Hyrax
  class PublicationsController < ApplicationController
    include Spot::WorksControllerBehavior

    self.curation_concern_type = ::Publication
    self.show_presenter = Hyrax::PublicationPresenter
  end
end
