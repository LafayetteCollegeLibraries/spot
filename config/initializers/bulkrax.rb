# config/initializers/bulkrax.rb 
Bulkrax.setup do |config| 
    # If the work type isn't provided during import, use Image 
    config.default_work_type = 'Image' 
 
    # Setup a field mapping for the OaiDcParser 
    # Your application metadata fields are the key 
    #   from: fields in the incoming source data 
    config.field_mappings = { 
        "Bulkrax::OaiDcParser" => {      
            "admin_set" => { from: ["admin_set"] }, 
            "date_uploaded" => { from: ["date_uploaded"] }, 
            "depositor" => { from: ["depositor"] }, 
            "discover_groups" => { from: ["discover_groups"] }, 
            "contributor" => { from: ["contributor"] }, 
            "creator" => { from: ["creator"] }, 
            "description" => { from: ["description"] }, 
            "identifier" => { from: ["identifier"] }, 
            "keyword" => { from: ["keyword"] }, 
            "language" => { from: ["language"] }, 
            "location" => { from: ["location"] }, 
            "note" => { from: ["note"] }, 
            "physical_medium" => { from: ["physical_medium"] }, 
            "publisher" => { from: ["publisher"] }, 
            "related_resource" => { from: ["related_resource"] }, 
            "resource_type" => { from: ["resource_type"] }, 
            "rights_holder" => { from: ["rights_holder"] }, 
            "rights_statement" => { from: ["rights_statement"] }, 
            "source" => { from: ["source"] }, 
            "subject" => { from: ["subject"] }, 
            "subtitle" => { from: ["subtitle"] }, 
            "title" => { from: ["title"] }, 
            "title_alternative" => { from: ["title_alternative"] }, 
            "academic_department" => { from: ["academic_department"] }, 
            "division" => { from: ["division"] }, 
            "organization" => { from: ["organization"] }, 
            "abstract" => { from: ["abstract"] }, 
            "bibliographic_citation" => { from: ["bibliographic_citation"] }, 
            "date_available" => { from: ["date_available"] }, 
            "date_issued" => { from: ["date_issued"] }, 
            "editor" => { from: ["editor"] }, 
            "license" => { from: ["license"] }, 
            "date" => { from: ["date"] }, 
            "date_associated" => { from: ["date_associated"] }, 
            "date_scope_note" => { from: ["date_scope_note"] }, 
            "donor" => { from: ["donor"] }, 
            "inscription" => { from: ["inscription"] }, 
            "original_item_extent" => { from: ["original_item_extent"] }, 
            "repository_location" => { from: ["repository_location"] }, 
            "requested_by" => { from: ["requested_by"] }, 
            "research_assistance" => { from: ["research_assistance"] }, 
            "subject_ocm" => { from: ["subject_ocm"] }, 
            "access_note" => { from: ["access_note"] }, 
            "advisor" => { from: ["advisor"] }, 
            "file_set_ids" => { from: ["file_set_ids"] }, 
            "file_size" => { from: ["file_size"] }, 
            "original_checksum" => { from: ["original_checksum"] }, 
            "page_count" => { from: ["page_count"] }, 
            "collection_slug" => { from: ["collection_slug"] }, 
            "sponsor" => { from: ["sponsor"] }, 
            "local_identifier" => { from: ["local_identifier"] }, 
            "permalink" => { from: ["permalink"] }, 
            "standard_identifier" => { from: ["standard_identifier"] }, 
            "date_modified" => { from: ["date_modified"] } 
        } 
    } 
end