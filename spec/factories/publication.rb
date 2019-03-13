# frozen_string_literal: true

FactoryBot.define do
  factory :publication do
    abstract { ['A short description of the thing'] }
    academic_department { ['Art'] }
    bibliographic_citation { ['Lastname, First. Title of piece.'] }
    contributor { ['Contributor, First-Name', 'Person, Another'] }
    creator { ['Creator, First-Name'] }
    date_issued { ['1986-02-11'] }
    date_available { ['2018-08-24'] }
    description { ['A description describes a thing', 'it contains multitudes'] }
    division { ['Humanities'] }
    editor { ['Sweeney, Mary'] }
    identifier { ['hdl:123/456', 'doi:00.000/00000'] }
    keyword { ['test', 'item', 'topic'] }
    language { ['en'] }
    organization { ['Lafayette College'] }
    place { [] }
    publisher { ['Prestigious Press', 'Lafayette College'] }
    resource_type { ['Article'] }
    rights_statement { [] }
    related_resource { ['http://cool-resource.org'] }
    source { ['Lafayette College', '_The_ Source for Good Publications'] }
    subject { ['Cheese - Other'] }
    subtitle { ['An exploration'] }
    title { ['A Prestigious Publication'] }
    title_alternative { ['A Pretty Popular Publication'] }

    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    trait :authenticated do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
    end

    trait :private do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    end

    transient do
      file { nil }
      file_set_params { nil }
      ingest_file { false }

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
        fs = FileSet.create
        actor = Hyrax::Actors::FileSetActor.new(fs, evaluator.user)
        actor.create_metadata(evaluator.file_set_params || {})
        actor.create_content(evaluator.file)
        actor.attach_to_work(work)

        if evaluator.ingest_file
          change_filename = ->(file_set) { file_set.original_file.file_name = File.basename(evaluator.file.path) }
          Hydra::Works::UploadFileToFileSet.call(fs, evaluator.file, additional_services: [change_filename])
        end
      end
    end
  end
end
