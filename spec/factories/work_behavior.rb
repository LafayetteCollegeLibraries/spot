# frozen_string_literal: true
#
# Base trait for common work properties. Don't use this directly, but instead
# inherit from when building out a factory for a work type that inherits from
# `Spot::CoreMetadata`
FactoryBot.define do
  trait :work_behavior do
    contributor { ['Contributor, First-Name', 'Person, Another'] }
    creator { ['Creator, Anne'] }
    description { ['An account of the resource'] }
    identifier { ['hdl:10385/abc123'] }
    keyword { ['photo'] }
    language { ['en'] }
    location { ['http://sws.geonames.org/5188140/'] }
    note { ['Some staff-side information'] }
    physical_medium { ['Photograph'] }
    publisher { ['Lafayette College'] }
    related_resource { ['http://another-resource.com'] }
    resource_type { ['Other'] }
    rights_holder { ['Holder, R.'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
    source { ['Lafayette College'] }
    subject { ['http://id.worldcat.org/fast/1061714'] }
    subtitle { ['An object to view'] }
    title { ['A Fabulous Work'] }
    title_alternative { ['An alternative title for the work.'] }

    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    transient do
      user { create(:user) }
    end

    before(:create) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end
  end

  trait :public do
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  end

  trait :authenticated do
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
  end

  trait :private do
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  end
end
