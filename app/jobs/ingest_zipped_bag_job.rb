# frozen_string_literal: true

class IngestZippedBagJob < ApplicationJob
  def perform(zip_path)
    IngestZippedBag.new(zip_path).perform
  end
end
