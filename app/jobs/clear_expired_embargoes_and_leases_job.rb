# frozen_string_literal: true
class ClearExpiredEmbargoesAndLeasesJob < ApplicationJob
  def perform
    ::Spot::EmbargoLeaseService.clear_all_expired(regenerate_thumbnails: true)
  end
end
