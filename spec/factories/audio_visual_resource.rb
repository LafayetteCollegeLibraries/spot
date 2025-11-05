# frozen_string_literal: true
FactoryBot.define do
  factory :audio_visual_resource_with_required_fields_only, parent: :base_work_resource, class: 'AudioVisualResource' do
    date { [Time.zone.now.strftime('%Y-%m-%d')] }
    resource_type { ['Other'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
  end

  factory :audio_visual_resource,
          parent: :audio_visual_resource_with_required_fields_only,
          traits: [:base_metadata, :audio_visual_metadata]
end
