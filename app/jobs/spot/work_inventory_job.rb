# frozen_string_literal: true
module Spot
  class WorkInventoryJob < ::ApplicationJob
    def perform
      Spot::WorkInventoryService.new.inventory
    end
  end
end
