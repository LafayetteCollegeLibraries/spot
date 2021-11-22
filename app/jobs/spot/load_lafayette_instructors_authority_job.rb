# frozen_string_literal: true
module Spot
  class LoadLafayetteInstructorsAuthorityJob < ::ApplicationJob
    # @todo We should probably query the current academic term and cache it (for a month?)
    #       before loading the instructors. For now, we'll stuff it with Winter 2021.
    def perform
      Spot::LafayetteInstructorsAuthorityService.load(term: '202103')
    end
  end
end
