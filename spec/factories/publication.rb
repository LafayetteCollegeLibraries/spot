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
    license { ['This is some licensing text'] }
    location { [] }
    note { ['a note about the thing'] }
    organization { ['Lafayette College'] }
    publisher { ['Prestigious Press', 'Lafayette College'] }
    resource_type { ['Article'] }
    rights_holder { ['Lafayette College'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
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
      user { create(:user) }
      content { nil }
      label { 'publication.pdf' }
    end

    before(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :publication_with_file_set do
      after(:create) do |pub, evaluator|
        fs_opts = { user: evaluator.user, title: ['Image FileSet'], label: evaluator.label }
        fs_opts[:content] = evaluator.content if evaluator.content
        fs_visibility = case pub.visibility
                        when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
                          :public
                        when Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
                          :authenticated
                        else
                          :private
                        end

        fs = create(:file_set, fs_visibility, **fs_opts)

        pub.ordered_members << fs
        pub.representative_id = fs.id
        pub.save
      end
    end


    before(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end
  end
end
