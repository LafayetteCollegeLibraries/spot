# frozen_string_literal: true
module Spot
  class RepositoryFixityCheckJob < ApplicationJob
    queue_as :low_priority

    # @param [true, false] :force Ignore the 'max days between check' parameter
    def perform(force: false)
      batch = Spot::FixityCheckService.perform(force: force)
      Spot::SendFixityStatusJob.perform_now(batch)
    end
  end
end
