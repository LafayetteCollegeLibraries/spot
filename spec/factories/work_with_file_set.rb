# frozen_string_literal: true
FactoryBot.define do
  trait :has_file_set do
    transient do
      content { nil }
      label { 'work.pdf' }
      file_set_title { 'FileSet' }
    end

    after(:create) do |work, evaluator|
      fs_opts = {
        title: [evaluator.file_set_title],
        label: evaluator.label
      }

      fs_opts[:user] = evaluator.user if evaluator.user
      fs_opts[:content] = evaluator.content if evaluator.content
      fs = create(:file_set, :public, **fs_opts)

      work.ordered_members << fs
      work.representative_id = fs.id
      work.save
    end
  end
end
