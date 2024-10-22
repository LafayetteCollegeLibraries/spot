# frozen_string_literal: true
#
# copied from Hyrax specs
# @see https://github.com/samvera/hyrax/blob/v2.5.1/spec/factories/file_sets.rb
FactoryBot.define do
  factory :file_set do
    transient do
      user { create(:user) }
      content { nil }
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    end

    after(:build) do |fs, evaluator|
      fs.apply_depositor_metadata evaluator.user.user_key
    end

    after(:create) do |fs, evaluator|
      Hydra::Works::UploadFileToFileSet.call(fs, evaluator.content) if evaluator.content.present?
    end

    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      read_groups { ["public"] }
    end

    trait :registered do
      read_groups { ["registered"] }
    end
  end
end
