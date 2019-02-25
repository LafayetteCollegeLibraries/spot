# frozen_string_literal: true
FactoryBot.define do
  factory :user do
    email { FFaker::Internet.unique.email }
    password { FFaker::Internet.password }
    display_name { "#{FFaker::Name.last_name}, #{FFaker::Name.first_name}" }
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
      groups { ['admin'] }
    end

    # from: https://github.com/samvera/hyrax/blob/v2.4.1/spec/factories/users.rb
    after(:build) do |user, evaluator|
      if evaluator.admin
        create(:admin_role, users: [user])
      end

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
