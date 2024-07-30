# frozen_string_literal: true
#
# Mixin traits to use when building factories for resources.
# Each trait mirrors the attributes of the respective schema
# in `config/metadata/{schema}.yaml`
FactoryBot.define do
  trait :base_metadata do
    bibliographic_citation { [] }
    contributor { [] }
    creator { [] }
    description { [] }
    identifier { [] }
    keyword { [] }
    language { [] }
    location { [] }
    note { [] }
    physical_medium { [] }
    publisher { [] }
    related_resource { [] }
    resource_type { [] }
    rights_holder { [] }
    rights_statement { [] }
    source { [] }
    source_identifier { [] }
    subject { [] }
    subtitle { [] }
    title_alternative { [] }
  end

  trait :core_metadata do
    title { [] }
    date_modified { }
    date_uploaded { }
    depositor { }
  end

  trait :image_metadata do
    date { [] }
    date_associated { [] }
    date_scope_note { [] }
    donor { [] }
    inscription { [] }
    original_item_extent { [] }
    repository_location { [] }
    requested_by { [] }
    research_assistance { [] }
    subject_ocm { [] }
  end

  trait :institutional_metadata do
    academic_department { [] }
    division { [] }
    organization { [] }
  end

  trait :publication_metadata do
    abstract { [] }
    date_issued { [] }
    date_available { [] }
    editor { [] }
    license { [] }
  end

  trait :student_work_metadata do
    abstract { [] }
    access_note { [] }
    advisor { [] }
    date { [] }
    date_available { [] }
  end
end