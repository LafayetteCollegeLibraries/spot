# frozen_string_literal: true
FactoryBot.define do
  factory :audio_visual, traits: [:work_behavior] do
    date { ['2023-10'] }
    embed_url { ['http://example.com/media/abc123def'] }
    title { ['Audio Visual Work'] }
  end

  factory :audio_visual_with_file_set, traits: [:has_file_set]
end
