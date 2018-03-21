FactoryBot.define do
  factory :user do
    email { FFaker::Internet.unique.email }
    password { FFaker::Internet.password }
    display_name { "#{FFaker::Name.last_name}, #{FFaker::Name.first_name}" }
    guest false
    roles []

    factory :guest_user do
      guest true
    end

    factory :admin_user do
      roles { [Role.where(name: 'admin').first_or_create] }
    end

    factory :trustee_user do
      roles { [Role.where(name: 'trustee').first_or_create] }
    end
  end
end
