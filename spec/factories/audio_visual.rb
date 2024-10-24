# frozen_string_literal: true
FactoryBot.define do
  factory :audio_visual, traits: [:work_behavior] do
    date { ['2019-12'] }
    date_associated { ['2019'] }
    inscription { ['hey look over here'] }
    original_item_extent { ['24 x 19.5 cm.'] }
    repository_location { ['On that one shelf in the back'] }
    research_assistance { ['Student, Ashley'] }
    provenance { ['Owned by Lafayette College'] }
    barcode { ['abcdefg'] }
    resource_type { ['Audio'] }
    premade_derivatives { ['sound.wav'] }
    stored_derivatives { ['sound.wav'] }
  end

  factory :audio_visual_with_file_set, traits: [:has_file_set]
end
