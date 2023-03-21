# frozen_string_literal: true
# config/initializers/bulkrax.rb
Bulkrax.setup do |config|
  # If the work type isn't provided during import, use Image
  config.default_work_type = 'Image'

  # Setup a field mapping for the CsvParser
  # Your application metadata fields are the key
  #   from: fields in the incoming source data
  config.field_mappings = {
    "Bulkrax::CsvParser" => {
      "admin_set" => { from: ["admin_set"], split: '\|' },
      "date_uploaded" => { from: ["date_uploaded"], split: '\|' },
      "depositor" => { from: ["depositor"], split: '\|' },
      "discover_groups" => { from: ["discover_groups"], split: '\|' },
      "contributor" => { from: ["contributor"], split: '\|' },
      "creator" => { from: ["creator"], split: '\|' },
      "description" => { from: ["description"], split: '\|' },
      "identifier" => { from: ["identifier"] },
      "keyword" => { from: ["keyword"], split: '\|' },
      "language" => { from: ["language"], split: '\|' },
      "location" => { from: ["location"], split: '\|' },
      "note" => { from: ["note"], split: '\|' },
      "physical_medium" => { from: ["physical_medium"], split: '\|' },
      "publisher" => { from: ["publisher"], split: '\|' },
      "related_resource" => { from: ["related_resource"], split: '\|' },
      "resource_type" => { from: ["resource_type"], split: '\|' },
      "rights_holder" => { from: ["rights_holder"], split: '\|' },
      "rights_statement" => { from: ["rights_statement"], split: '\|' },
      "source" => { from: ["source"], split: '\|' },
      "source_identifier" => { from: ["source_identifier"] },
      "subject" => { from: ["subject"], split: '\|' },
      "subtitle" => { from: ["subtitle"], split: '\|' },
      "title" => { from: ["title"], split: '\|' },
      "title_alternative" => { from: ["title_alternative"], split: '\|' },
      "academic_department" => { from: ["academic_department"], split: '\|' },
      "division" => { from: ["division"], split: '\|' },
      "organization" => { from: ["organization"], split: '\|' },
      "abstract" => { from: ["abstract"], split: '\|' },
      "bibliographic_citation" => { from: ["bibliographic_citation"], split: '\|' },
      "date_available" => { from: ["date_available"], split: '\|' },
      "date_issued" => { from: ["date_issued"], split: '\|' },
      "editor" => { from: ["editor"], split: '\|' },
      "license" => { from: ["license"], split: '\|' },
      "date" => { from: ["date"], split: '\|' },
      "date_associated" => { from: ["date_associated"], split: '\|' },
      "date_scope_note" => { from: ["date_scope_note"], split: '\|' },
      "donor" => { from: ["donor"], split: '\|' },
      "inscription" => { from: ["inscription"], split: '\|' },
      "original_item_extent" => { from: ["original_item_extent"], split: '\|' },
      "repository_location" => { from: ["repository_location"], split: '\|' },
      "requested_by" => { from: ["requested_by"], split: '\|' },
      "research_assistance" => { from: ["research_assistance"], split: '\|' },
      "subject_ocm" => { from: ["subject_ocm"], split: '\|' },
      "access_note" => { from: ["access_note"], split: '\|' },
      "advisor" => { from: ["advisor"], split: '\|' },
      "file_set_ids" => { from: ["file_set_ids"], split: '\|' },
      "file_size" => { from: ["file_size"], split: '\|' },
      "original_checksum" => { from: ["original_checksum"], split: '\|' },
      "page_count" => { from: ["page_count"], split: '\|' },
      "collection_slug" => { from: ["collection_slug"], split: '\|' },
      "sponsor" => { from: ["sponsor"], split: '\|' },
      "local_identifier" => { from: ["local_identifier"], split: '\|' },
      "permalink" => { from: ["permalink"], split: '\|' },
      "standard_identifier" => { from: ["standard_identifier"], split: '\|' },
      "date_modified" => { from: ["date_modified"], split: '\|' }
    }
  }
end
