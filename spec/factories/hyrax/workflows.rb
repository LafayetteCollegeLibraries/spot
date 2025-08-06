# frozen_string_literal: true
#
# Borrowing factories from Hyrax source, as the files aren't available in the gem.
#
# @todo When upgrading to Hyrax 5.1.0, remove the files in spec/factories/hyrax and replace them
#       with relevant calls to `require 'hyrax/specs/shared_specs/factories/factory.rb` in spec_helper.rb
FactoryBot.define do
  factory :workflow, class: Sipity::Workflow do
    sequence(:name) { |n| "generic_work-#{n}" }
    permission_template
  end
end