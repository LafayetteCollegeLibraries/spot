# frozen_string_literal: true
FactoryBot.define do
  factory :publication_resource, traits: [:core_metadata, :base_metadata, :institutional_metadata, :publication_metadata] do
    # wot?
  end
end