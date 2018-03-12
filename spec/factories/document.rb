FactoryBot.define do
  factory :document do
    id { ActiveFedora::Noid::Service.new.mint }
    title [FFaker::Book.title]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    admin_set do
      AdminSet.find(AdminSet.find_or_create_default_admin_set_id)
    end

    creator { ["#{FFaker::Name.last_name}, #{FFaker::Name.first_name}"] }

    depositor do
      u = create(:user, display_name: creator.first)
      u.user_key
    end
  end
end
