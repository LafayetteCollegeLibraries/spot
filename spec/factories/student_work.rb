# frozen_string_literal: true
#
FactoryBot.define do
  factory :student_work, traits: [:work_behavior] do
    abstract { ['A short description of the thing'] }
    access_note { ['Here is how to access the thing'] }
    academic_department { ['Libraries'] }
    advisor { ['Prof. Smartfellow'] }
    bibliographic_citation { ['A. Book, somewhere'] }
    creator { ['Student, Anne'] }
    date { ['2021-10-20'] }
    date_available { ['2021-10-20'] }
    description { ['A longer description of the thing'] }
    division { ['Humanities'] }
    keyword { ['Student works'] }
    identifier { ['hdl:10385/paper-111'] }
    language { ['en'] }
    note { ['Here is a note'] }
    organization { ['Lafayette College'] }
    related_resource { ['https://www.lafayette.edu'] }
    resource_type { ['Research Paper'] }
    rights_statement { ['http://creativecommons.org/publicdomain/zero/1.0/'] }
    subject { ['http://id.worldcat.org/fast/895423'] }
    title { ['Student Work, Submitted'] }

    factory :student_work_with_file_set, traits: [:has_file_set]
  end
end
