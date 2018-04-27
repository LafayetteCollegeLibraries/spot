FactoryBot.define do
  factory :document do
    id { NoidSupport.assign_id }

    title [FFaker::Book.title]
    date_created { [FFaker::Time.date] }

    admin_set do
      AdminSet.find(AdminSet.find_or_create_default_admin_set_id)
    end

    trait :public do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    trait :authenticated do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    end

    trait :private do
      visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end

    transient do
      file { nil }

      # Hyrax Works always need a depositor, otherwise the
      # filter_suppressed_with_roles search builder raises:
      #
      #      NoMethodError:
      #        undefined method `first' for nil:NilClass
      #
      # https://github.com/samvera/hyrax/commit/2daec42842497057741ec95162074ea9397318fa#diff-c34834626a3b0ac8c846cda6457fe38aR34
      user { create(:user) }
    end

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key) if evaluator.user

      # TODO: add ability to attach multiple files
      unless evaluator.file.nil?
        actor = Hyrax::Actors::FileSetActor.new(FileSet.create, evaluator.user)
        actor.create_metadata({})
        actor.create_content(Hyrax::UploadedFile.create(file: evaluator.file))
        actor.attach_to_work(work)
      end
    end
  end
end
