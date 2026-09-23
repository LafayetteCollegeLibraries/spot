# frozen_string_literal: true
module Hyrax
  class AudioVisualsController < ApplicationController
    include ::Spot::WorksControllerBehavior

    self.curation_concern_type = Hyrax.config.use_valkyrie? ? AudioVisualResource : AudioVisual
    self.show_presenter = Hyrax::AudioVisualPresenter
  end
end
