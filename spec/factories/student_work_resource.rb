# frozen_string_literal: true
FactoryBot.define do
  factory :student_work_resource_with_required_fields_only, parent: :base_resource, class: 'StudentWorkResource' do
    academic_department { ['Libraries'] }
    advisor { ['Professor, Anne Esteemed'] }
    creator { ['Creator, A.'] }
    description { ['Description of StudentWork'] }
    date { [Time.zone.now.strftime('%Y-%m-%d')] }
    resource_type { ['Other'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
  end

  factory :student_work_resource,
          parent: :student_work_resource_with_required_fields_only,
          traits: [:base_metadata, :institutional_metadata, :student_work_metadata] do

  end
end
