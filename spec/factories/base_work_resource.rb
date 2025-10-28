# frozen_string_literal: true
#
# Common traits for work-classes (file_set handling in particular). It's recommended to
# inherit work resource factories from this factory, rather than :base_resource. Exposes
# an :include_file_sets trait that can either be `true` or an
#
#
# @example
#  FactoryBot.define do
#    factory :book_resource, parent: :base_work_resource, class: 'BookResource' do
#      # ...
#    end
#  end
#
# @example Creating a work with a file_set (depositor is new user)
#   RSpec.describe do
#     let(:work_with_file_set) { FactoryBot.valkyrie_create(:work_resource, include_file_sets: true) }
#   end
#
# @example Creating a work with a specific file
#   RSpec.describe do
#     let(:fixture_path) { Rails.root.join('spec', 'fixtures', 'a_fixture.pdf') }
#     let(:work_with_file_set) { FactoryBot.valkryie_create(:work_resource, include_file_sets: [fixture_path]) }
#   end
#
FactoryBot.define do
  factory :base_work_resource, parent: :base_resource, class: 'Hyrax::Work' do
    transient do
      include_file_sets { nil }
    end

    trait :with_file_set do
      include_file_sets { true }
    end

    after(:create) do |work, evaluator|
      next unless evaluator.include_file_sets

      fixture_path = Rails.root.join('spec', 'fixtures', 'image_transcript.vtt') # @todo we need a more universal name for this file
      files = evaluator.include_file_sets == true ? Array.wrap(fixture_path) : Array.wrap(evaluator.include_file_sets)
      depositor = User.find_by(email: work.depositor) || FactoryBot.create(:user)

      files.each do |path|
        uploaded_file = Hyrax::UploadedFile.create!(file: File.open(path), user: depositor)
        AttachFilesToWorkJob.perform_now(work, [uploaded_file])
      end
    end
  end
end
