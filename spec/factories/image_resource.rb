# frozen_string_literal: true
FactoryBot.define do
  factory :image_resource, traits: [:core_metadata, :base_metadata, :image_metadata]
end
