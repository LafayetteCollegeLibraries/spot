# frozen_string_literal: true
FactoryBot.define do
  factory :role do
    factory :admin_role do
      name { 'admin' }
    end

    factory :depositor_role do
      name { 'depositor' }
    end

    initialize_with { Role.find_or_initialize_by(name: name) }
  end
end
