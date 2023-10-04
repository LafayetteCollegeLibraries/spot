# frozen_string_literal: true
# config/initializers/bulkrax.rb
Bulkrax.setup do |config|
  # If the work type isn't provided during import, use Image
  config.default_work_type = 'Image'

  # Setup a field mapping for the CsvParser
  # Your application metadata fields are the key
  #   from: fields in the incoming source data
  config.field_mappings = {
    "Bulkrax::CsvSpotParser" => {
      "admin_set" => { from: ["admin_set"], split: '\|', join: '|' },
      "date_uploaded" => { from: ["date_uploaded"], split: '\|', join: '|' },
      "depositor" => { from: ["depositor"], split: '\|', join: '|' },
      "discover_groups" => { from: ["discover_groups"], split: '\|', join: '|' },
      "contributor" => { from: ["contributor"], split: '\|', join: '|' },
      "creator" => { from: ["creator"], split: '\|', join: '|' },
      "description" => { from: ["description"], split: '\|', join: '|' },
      "identifier" => { from: ["identifier"], join: '|' },
      "keyword" => { from: ["keyword"], split: '\|', join: '|' },
      "language" => { from: ["language"], split: '\|', join: '|' },
      "location" => { from: ["location"], split: '\|', join: '|' },
      "note" => { from: ["note"], split: '\|', join: '|' },
      "physical_medium" => { from: ["physical_medium"], split: '\|', join: '|' },
      "publisher" => { from: ["publisher"], split: '\|', join: '|' },
      "related_resource" => { from: ["related_resource"], split: '\|', join: '|' },
      "resource_type" => { from: ["resource_type"], split: '\|', join: '|' },
      "rights_holder" => { from: ["rights_holder"], split: '\|', join: '|' },
      "rights_statement" => { from: ["rights_statement"], split: '\|', join: '|' },
      "source" => { from: ["source"], split: '\|', join: '|' },
      "source_identifier" => { from: ["source_identifier"], join: '|' },
      "subject" => { from: ["subject"], split: '\|', join: '|' },
      "subtitle" => { from: ["subtitle"], split: '\|', join: '|' },
      "title" => { from: ["title"], split: '\|', join: '|' },
      "title_alternative" => { from: ["title_alternative"], split: '\|', join: '|' },
      "academic_department" => { from: ["academic_department"], split: '\|', join: '|' },
      "division" => { from: ["division"], split: '\|', join: '|' },
      "organization" => { from: ["organization"], split: '\|', join: '|' },
      "abstract" => { from: ["abstract"], split: '\|', join: '|' },
      "bibliographic_citation" => { from: ["bibliographic_citation"], split: '\|', join: '|' },
      "date_available" => { from: ["date_available"], split: '\|', join: '|' },
      "date_issued" => { from: ["date_issued"], split: '\|', join: '|' },
      "editor" => { from: ["editor"], split: '\|', join: '|' },
      "license" => { from: ["license"], split: '\|', join: '|' },
      "date" => { from: ["date"], split: '\|', join: '|' },
      "date_associated" => { from: ["date_associated"], split: '\|', join: '|' },
      "date_scope_note" => { from: ["date_scope_note"], split: '\|', join: '|' },
      "donor" => { from: ["donor"], split: '\|', join: '|' },
      "inscription" => { from: ["inscription"], split: '\|', join: '|' },
      "original_item_extent" => { from: ["original_item_extent"], split: '\|', join: '|' },
      "repository_location" => { from: ["repository_location"], split: '\|', join: '|' },
      "requested_by" => { from: ["requested_by"], split: '\|', join: '|' },
      "research_assistance" => { from: ["research_assistance"], split: '\|', join: '|' },
      "subject_ocm" => { from: ["subject_ocm"], split: '\|', join: '|' },
      "access_note" => { from: ["access_note"], split: '\|', join: '|' },
      "advisor" => { from: ["advisor"], split: '\|', join: '|' },
      "file_set_ids" => { from: ["file_set_ids"], split: '\|', join: '|' },
      "file_size" => { from: ["file_size"], split: '\|', join: '|' },
      "original_checksum" => { from: ["original_checksum"], split: '\|', join: '|' },
      "page_count" => { from: ["page_count"], split: '\|', join: '|' },
      "collection_slug" => { from: ["collection_slug"], split: '\|', join: '|' },
      "sponsor" => { from: ["sponsor"], split: '\|', join: '|' },
      "local_identifier" => { from: ["local_identifier"], split: '\|', join: '|' },
      "permalink" => { from: ["permalink"], split: '\|', join: '|' },
      "standard_identifier" => { from: ["standard_identifier"], split: '\|', join: '|' },
      "date_modified" => { from: ["date_modified"], split: '\|', join: '|' },
      "member_ids" => { from: ["member_ids"], split: '\|', join: '|', related_children_field_mapping: true },
      "member_of_collection_ids" => { from: ["member_of_collection_ids"], split: '\|', join: '|', related_parents_field_mapping: true }
    }
  }

  # Remove the QualifiedDC parser
  config.parsers -= [{ name: "OAI - Qualified Dublin Core", class_name: "Bulkrax::OaiQualifiedDcParser", partial: "oai_fields" }]

  # Remove the DC parser
  config.parsers -= [{ name: "OAI - Dublin Core", class_name: "Bulkrax::OaiDcParser", partial: "oai_fields" }]

  # Remove the Bagit parser
  config.parsers -= [{ name: "Bagit", class_name: "Bulkrax::BagitParser", partial: "bagit_fields" }]

  # Remove the XML parser
  config.parsers -= [{ name: "XML", class_name: "Bulkrax::XmlParser", partial: "xml_fields" }]

  # Remove the original CSV parser
  config.parsers -= [{ name: "CSV - Comma Separated Values", class_name: "Bulkrax::CsvParser", partial: "csv_fields" }]

  # Add custom CSV parser
  config.parsers += [{ name: "CSV - Lafayette", class_name: "Bulkrax::CsvSpotParser", partial: "csv_fields" }]

  config.fill_in_blank_source_identifiers = lambda do |parser, index|
    metadata = parser.records(index)
    filename = File.basename(metadata[index][:file_1], '.*')
    "#{filename}-#{parser.importerexporter.id}-#{index}"
  end

  config.import_path = Rails.root.join('tmp', 'uploads', 'bulkrax', 'imports')
  config.export_path = Rails.root.join('tmp', 'uploads', 'bulkrax', 'exports')

  config.multi_value_element_join_on = ' | '
end
