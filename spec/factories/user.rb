FactoryBot.define do
  factory :user do
    email { FFaker::Internet.unique.email }
    password { FFaker::Internet.password }
    display_name { "#{FFaker::Name.last_name}, #{FFaker::Name.first_name}" }
  end
end
