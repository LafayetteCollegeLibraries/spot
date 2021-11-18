# frozen_string_literal: true

FactoryBot.define do
  factory :publication, traits: [:work_behavior] do
    abstract { ['A short description of the thing'] }
    academic_department { ['Art'] }
    bibliographic_citation { ['Lastname, First. Title of piece.'] }
    date_issued { ['1986-02-11'] }
    date_available { ['2018-08-24'] }
    division { ['Humanities'] }
    editor { ['Sweeney, Mary'] }
    license { ['This is some licensing text'] }
    organization { ['Lafayette College'] }
    resource_type { ['Article'] }

    transient do
      file_set_title { 'Publication FileSet' }
    end

    factory :publication_with_file_set, traits: [:has_file_set]
  end
end
