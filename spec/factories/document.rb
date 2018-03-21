FactoryBot.define do
  factory :document do
    id { ActiveFedora::Noid::Service.new.mint }
    title [FFaker::Book.title]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC

    transient do
      user { nil }
      pdf { nil }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)

      if evaluator.pdf
        actor = Hyrax::Actors::FileSetActor.new(FileSet.create, evaluator.user)
        actor.create_metadata({})
        actor.create_content(Hyrax::UploadedFile.create(file: evaluator.pdf))
        actor.attach_to_work(work)
      end
    end

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
