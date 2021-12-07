# frozen_string_literal: true
FactoryBot.define do
  factory :image, traits: [:work_behavior] do
    date { ['2019-12'] }
    date_associated { ['2019'] }
    date_scope_note { ['Printed information on the backs of postcards that provides information relevent to dating the postcard itself (not the image).'] }
    donor { ['Alumnus, Anne Esteemed'] }
    inscription { ['hey look over here'] }
    original_item_extent { ['24 x 19.5 cm.'] }
    repository_location { ['On that one shelf in the back'] }
    requested_by { ['Requester, Jennifer Q.'] }
    research_assistance { ['Student, Ashley'] }
    resource_type { ['Image'] }
    subject_ocm { ['000 VALUE'] }
  end

  factory :image_with_file_set, traits: [:has_file_set]
end
