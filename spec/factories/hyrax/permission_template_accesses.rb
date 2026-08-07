# frozen_string_literal: true
#
# Borrowing factories from Hyrax source, as the files aren't available in the gem.
#
# @todo When upgrading to Hyrax 5.1.0, remove the files in spec/factories/hyrax and replace them
#       with relevant calls to `require 'hyrax/specs/shared_specs/factories/factory.rb` in spec_helper.rb
FactoryBot.define do
  factory :permission_template_access, class: Hyrax::PermissionTemplateAccess do
    permission_template
    trait :manage do
      access { 'manage' }
    end

    trait :deposit do
      access { 'deposit' }
    end

    trait :view do
      access { 'view' }
    end
  end
end
