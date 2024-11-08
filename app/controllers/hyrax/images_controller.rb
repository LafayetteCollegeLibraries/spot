# frozen_string_literal: true
module Hyrax
  class ImagesController < ApplicationController
    include ::Spot::WorksControllerBehavior

    self.curation_concern_type = ::Image
    self.show_presenter = Hyrax::ImagePresenter
  end
end
