# frozen_string_literal: true
FactoryBot.define do
  factory :publication_resource_with_required_fields_only, parent: :base_work_resource, class: 'PublicationResource' do
    date_issued { [Time.zone.now.strftime('%Y-%m-%d')] }
    resource_type { ['Other'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
  end

  factory :publication_resource,
          parent: :publication_resource_with_required_fields_only,
          traits: [:base_metadata, :institutional_metadata, :publication_metadata] do
  end
end
