# frozen_string_literal: true

class IngestZippedBagJob < ApplicationJob
  def perform(zip_path)
    Spot::IngestZippedBag.new(zip_path).perform
  end
end
