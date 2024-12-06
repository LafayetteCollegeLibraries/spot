# frozen_string_literal: true
FactoryBot.define do
  factory :embargo, class: 'Hyrax::Embargo' do
    visibility_during_embargo { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    visibility_after_embargo { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    embargo_release_date { DateTime.now.utc + 1.day }
  end

  factory :lease, class: 'Hyrax::Lease' do
    visibility_during_lease { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    visibility_after_lease { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    lease_expiration_date { DateTime.now.utc + 1.day }
  end
end