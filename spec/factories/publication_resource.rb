# frozen_string_literal: true
FactoryBot.define do
  factory :publication_resource, traits: [:core_metadata, :base_metadata, :institutional_metadata, :publication_metadata] do
    # wot?
  end

  factory :publication_resource_with_required_fields_only, traits: [:core_metadata], class: 'PublicationResource' do
    date_issued { [Time.zone.now.strftime('%Y-%m-%d')] }
    resource_type { ['Other'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
  end
end
