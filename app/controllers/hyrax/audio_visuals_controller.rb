# frozen_string_literal: true
module Hyrax
  class AudioVisualsController < ApplicationController
    include ::Spot::WorksControllerBehavior

    # @todo for valkyrization
    # self.curation_concern_type = Hyrax.config.use_valkyrie? ? AudioVisualResource : AudioVisual
    self.curation_concern_type = ::AudioVisual
    self.show_presenter = Hyrax::AudioVisualPresenter
  end
end
