# frozen_string_literal: true
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person-#{n}@lafayette.edu" }
    sequence(:display_name) { |n| "Lastname, First (##{n})" }
    sequence(:lnumber) { |n| format("L%08d", n) }
    guest { false }
    roles { [] }

    transient do
      admin { false }
      groups { [] }
    end

    trait :guest do
      guest { true }
    end

    factory :admin_user do
      admin { true }
      groups { ['admin', 'registered', 'public'] }
      roles { [create(:admin_role), create(:depositor_role)] }
    end

    factory :depositor_user do
      groups { ['depositor', 'registered', 'public'] }
      roles { [create(:depositor_role)] }
    end

    factory :faculty_user do
      groups { ['registered', 'faculty', 'public'] }
      roles { [create(:faculty_role)] }
    end

    factory :registered_user do
      groups { ['registered', 'public'] }
      roles { [] }
    end

    factory :public_user do
      groups { ['public'] }
      guest { true }
    end

    factory :student_user do
      groups { ['registered', 'student', 'public'] }
      roles { [create(:student_role)] }
    end

    after(:build) do |user, evaluator|
      # from: https://github.com/samvera/hyrax/blob/v2.4.1/spec/factories/users.rb
      #
      # In case we have the instance but it has not been persisted
      ::RSpec::Mocks.allow_message(user, :groups).and_return(Array.wrap(evaluator.groups))
      # Given that we are stubbing the class, we need to allow for the original to be called
      ::RSpec::Mocks.allow_message(user.class.group_service, :fetch_groups).and_call_original
      # We need to ensure that each instantiation of the admin user behaves as expected.
      # This resolves the issue of both the created object being used as well as re-finding the created object.
      ::RSpec::Mocks.allow_message(user.class.group_service, :fetch_groups).with(user: user).and_return(Array.wrap(evaluator.groups))
    end
  end
end
