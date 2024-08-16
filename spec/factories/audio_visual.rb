# frozen_string_literal: true
FactoryBot.define do
  factory :audio_visual, traits: [:work_behavior] do
    date { ['2019-12'] }
  end

  factory :audio_visual_with_file_set, traits: [:has_file_set]
end
