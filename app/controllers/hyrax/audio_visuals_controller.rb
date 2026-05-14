# frozen_string_literal: true
module Hyrax
  class AudioVisualsController < ApplicationController
    include ::Spot::WorksControllerBehavior

    # self.curation_concern_type = ::AudioVisual
    self.curation_concern_type = ::PublicationResource
    self.work_form_service = Hyrax::FormFactory.new

    self.show_presenter = Hyrax::AudioVisualPresenter
  end
end
