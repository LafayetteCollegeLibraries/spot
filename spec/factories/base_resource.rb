# frozen_string_literal: true
#
# Abstracts common resource traits into a separate factory for inheritance, namely visibility
# settings. Works should inherit from :base_work_resource (@see spec/factories/base_work_resource.rb)
# which adds support for attaching `Hyrax::FileSet`s to works.
#
# @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/spec/factories/hyrax_work.rb
FactoryBot.define do
  factory :base_resource, traits: [:core_metadata], class: 'Hyrax::Resource' do
    transient do
      with_index { true }
      visibility_setting { nil }
    end

    after :build do |work, evaluator|
      work.visibility = evaluator.visibility_setting if evaluator.visibility_setting
    end

    after :create do |work, evaluator|
      if evaluator.visibility_setting
        work.visibility = evaluator.visibility_setting
        work.permission_manager.acl.save
      end

      Hyrax.index_adapter.save(resource: work) if evaluator.with_index
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
