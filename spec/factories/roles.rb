# frozen_string_literal: true
FactoryBot.define do
  factory :role do
    factory :admin_role do
      name { Ability.admin_group_name }
    end

    factory :depositor_role do
      name { Ability.depositor_group_name }
    end

    factory :faculty_role do
      name { Ability.faculty_group_name }
    end

    factory :student_role do
      name { Ability.student_group_name }
    end

    initialize_with { Role.find_or_initialize_by(name: name) }
  end
end
