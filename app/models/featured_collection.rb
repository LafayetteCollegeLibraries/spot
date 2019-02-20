# frozen_string_literal: true
class FeaturedCollection < ApplicationRecord
  FEATURE_LIMIT = 4

  validate :count_within_limit, on: :create
  validates :order, inclusion: { in: proc { 0..FEATURE_LIMIT } }

  # @return [true,false]
  def self.can_create_another?
    count < FEATURE_LIMIT
  end

  private

    # @return [void]
    def count_within_limit
      return if FeaturedCollection.can_create_another?
      errors.add(:base, "Limited to #{FEATURE_LIMIT} featured collections.")
    end
end
