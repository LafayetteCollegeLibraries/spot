# frozen_string_literal: true
FactoryBot.define do
  factory :student_work_resource, traits: [:core_metadata, :base_metadata, :institutional_metadata, :student_work_metadata]
end