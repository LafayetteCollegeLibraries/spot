# frozen_string_literal: true
#
# Mixin traits to use when building factories for resources.
# Each trait mirrors the attributes of the respective schema
# in `config/metadata/{schema}.yaml`
FactoryBot.define do
  trait :base_metadata do
    bibliographic_citation { ['Lastname, First. Title of piece.'] }
    contributor { ['Contributor, First-Name', 'Person, Another'] }
    creator { ['Creator, Anne'] }
    description { ['An account of the resource'] }
    identifier { ['hdl:10385/abc123'] }
    keyword { ['photo'] }
    language { ['en'] }
    location { ['http://sws.geonames.org/5188140/'] }
    note { ['Some staff-side information'] }
    physical_medium { ['Photograph'] }
    publisher { ['Lafayette College'] }
    related_resource { ['http://another-resource.com'] }
    resource_type { ['Other'] }
    rights_holder { ['Holder, R.'] }
    rights_statement { ['http://creativecommons.org/publicdomain/mark/1.0/'] }
    source { ['Lafayette College'] }
    source_identifier { [] }
    subject { ['http://id.worldcat.org/fast/1061714'] }
    subtitle { ['An object to view'] }
    title { ['A Fabulous Work'] }
    title_alternative { ['An alternative title for the work.'] }
  end

  trait :core_metadata do
    title { |n| ["Title of work (#{n})"] }
    date_modified { Time.now.utc }
    date_uploaded { Time.now.utc }
    depositor { 'repository@lafayette.edu' }
  end

  trait :image_metadata do
    date { ['2024-11'] }
    date_associated { ['2024'] }
    date_scope_note { ['Printed information on the backs of postcards that provides information relevent to dating the postcard itself (not the image).'] }
    donor { ['Alumnus, Anne Esteemed'] }
    inscription { ['hey look over here'] }
    original_item_extent { ['24 x 19.5 cm.'] }
    repository_location { ['On that one shelf in the back'] }
    requested_by { ['Requester, Jennifer Q.'] }
    research_assistance { ['Student, Ashley'] }
    subject_ocm { ['000 VALUE'] }
  end

  trait :institutional_metadata do
    academic_department { ['Art'] }
    division { ['Humanities'] }
    organization { ['Lafayette College'] }
  end

  trait :publication_metadata do
    abstract { ['A short description of the thing'] }
    date_issued { [Time.zone.now.strftime('%Y-%m-%d')] }
    date_available { ['2024-11-08'] }
    editor { ['Sweeney, Mary'] }
    license { ['This is some licensing text'] }
  end

  trait :student_work_metadata do
    abstract { ['A short description of the thing'] }
    access_note { ['Here is how to access the thing'] }
    advisor { ['Smartfellow, Jane'] }
    date { ['2024-11-08'] }
    date_available { ['2024-11-08'] }
  end

  trait :audio_visual_metadata do
    date { ['2024-11'] }
    date_associated { ['2024'] }
    inscription { ['hey look over here'] }
    original_item_extent { ['24 x 19.5 cm.'] }
    repository_location { ['On that one shelf in the back'] }
    research_assistance { ['Student, Ashley'] }
    provenance { ['Owner Information'] }
    barcode { ['abc123'] }
  end
end
