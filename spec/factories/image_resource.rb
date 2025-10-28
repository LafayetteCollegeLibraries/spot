# frozen_string_literal: true
FactoryBot.define do
  factory :image_resource_with_required_fields_only, parent: :base_work_resource, class: 'ImageResource' do
    date { [Time.zone.now.strftime('%Y-%m-%d')] }
    resource_type { ['Other'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
  end

  factory :image_resource,
          parent: :image_resource_with_required_fields_only,
          traits: [:base_metadata, :image_metadata]
end
