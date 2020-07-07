# frozen_string_literal: true
FactoryBot.define do
  factory :image do
    contributor { [] }
    creator { ['Photographer, A.'] }
    date { ['2019-12'] }
    date_associated { ['2019'] }
    date_scope_note { ['Printed information on the backs of postcards that provides information relevent to dating the postcard itself (not the image).'] }
    description { ['An account of the resource'] }
    donor { ['Alumnus, Anne Esteemed'] }
    identifier { ['hdl:10385/abc123'] }
    inscription { ['hey look over here'] }
    keyword { ['photo'] }
    language { ['en'] }
    location { ['http://sws.geonames.org/5188140/'] }
    note { ['Some staff-side information'] }
    original_item_extent { ['24 x 19.5 cm.'] }
    physical_medium { ['Photograph'] }
    publisher { ['Lafayette College'] }
    related_resource { ['http://another-resource.com'] }
    repository_location { ['On that one shelf in the back'] }
    requested_by { ['Requester, Jennifer Q.'] }
    research_assistance { ['Student, Ashley'] }
    resource_type { ['Image'] }
    rights_holder { ['Holder, R.'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
    source { ['A grouped collection'] }
    subject { ['http://id.worldcat.org/fast/1061714'] }
    subject_ocm { ['000 VALUE'] }
    subtitle { ['A closer look'] }
    title { ['An archival image'] }
    title_alternative { ['An alternative title of the image'] }

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
      label { 'image.png' }
    end

    before(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :image_with_file_set do
      after(:create) do |image, evaluator|
        fs_opts = {
          user: evaluator.user,
          title: ['Image FileSet'],
          label: evaluator.label
        }

        fs_opts[:content] = evaluator.content if evaluator.content
        fs = create(:file_set, :public, **fs_opts)

        image.ordered_members << fs
        image.representative_id = fs.id
        image.save
      end
    end

    before(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end
  end
end
