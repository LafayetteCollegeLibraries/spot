# frozen_string_literal: true
#
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/spec/factories/hyrax_work.rb
FactoryBot.define do
  factory :base_resource, traits: [:core_metadata], class: 'Hyrax::Work' do
    transient do
      visibility_setting { nil }
    end

    # rubocop:disable Style/IfUnlessModifier
    after :build do |work, evaluator|
      if evaluator.visibility_setting
        Hyrax::VisibilityWriter.new(resource: work).assign_access_for(visibility: evaluator.visibility_setting)
      end
    end
    # rubocop:enable Style/IfUnlessModifier

    after :create do |work, evaluator|
      if evaluator.visibility_setting
        Hyrax::VisibilityWriter.new(resource: work).assign_access_for(visibility: evaluator.visibility_setting)
        work.permission_manager.acl.save
      end
    end

    trait :public do
      transient do
        visibility_setting { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      end
    end

    trait :lafayette_only do
      transient do
        visibility_setting { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
      end
    end

    # @todo does this work?
    trait :metadata_only do
      transient do
        visibility_setting { 'metadata' }
      end
    end

    trait :private do
      transient do
        visibility_setting { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      end
    end
  end
end
