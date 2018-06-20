# frozen_string_literal: true

class IngestZippedBagJob < ApplicationJob
  # `source` needs to be a string, as job arguments can't contain symbols
  def perform(zip_path, source:)
    Spot::IngestZippedBag.new(zip_path, source: source.to_sym).perform
  end
end
