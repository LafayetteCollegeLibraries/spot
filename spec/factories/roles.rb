# frozen_string_literal: true
FactoryBot.define do
  factory :role do
    factory :admin_role do
      name { 'admin' }
    end
  end
end
