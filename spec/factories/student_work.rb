# frozen_string_literal: true
#
FactoryBot.define do
  factory :student_work, traits: [:work_behavior] do
    abstract { ['A short description of the thing'] }
    access_note { ['Here is how to access this thing'] }
    advisor { ['Prof. Smartfellow'] }
    bibliographic_citation { ['A. Book, somewhere'] }
    date { ['2021-10-20'] }
    date_available { ['2021-10-20'] }

    # to help with debugging maybe
    creator { ['Student, A.'] }
    title { ['Student Work, Submitted'] }

    factory :student_work_with_file_set, traits: [:has_file_set]
  end
end
