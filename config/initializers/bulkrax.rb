# frozen_string_literal: true
Bulkrax.setup do |config|
  # Add local parsers
  # config.parsers += [
  #   { name: 'MODS - My Local MODS parser', class_name: 'Bulkrax::ModsXmlParser', partial: 'mods_fields' },
  # ]
  config.parsers = [
    { name: 'CSV Parser', class_name: 'Spot::CsvParser', partial: 'csv_fields' }
  ]

  # WorkType to use as the default if none is specified in the import
  # Default is the first returned by Hyrax.config.curation_concerns
  config.default_work_type = Hyrax.config.curation_concerns.first.to_s

  # Similarly to our `Spot::SolrDocumentAttributes` mixin, the parsers need
  # to be aware of every metadata field we'd like to include across all models
  # and mixins. As exporters sort these fields alphabetically, and
  # `CsvEntry#build_mapping_metadata` will skip fields the model doesn't respond_to,
  # the order doesn't really matter. I'll be following the order/convention set
  # by the SolrDocument mixin.
  #
  # Controlled fields and internal user fields (`depositor`, `advisor`) are handled
  # by Spot::CsvEntry#build_export_metadata
  #
  # @see https://github.com/samvera-labs/bulkrax/blob/v2.0.0/app/models/bulkrax/csv_entry.rb#L120
  config.field_mappings['Spot::CsvParser'] = {
    # Hyrax properties
    'date_uploaded' => { from: ['date_uploaded'] },
    'work_type' => { from: ['model'] },

    # Spot::CoreMetadata mixin properties
    'contributor' => { from: ['contributor'] },
    'creator' => { from: ['creator'] },
    'description' => { from: ['description'] },
    'identifier' => { from: ['identifier'] },
    'keyword' => { from: ['keyword'] },
    'language' => { from: ['language'] },
    'location' => { from: ['location'] },
    'note' => { from: ['note'] },
    'physical_medium' => { from: ['physical_medium'] },
    'publisher' => { from: ['publisher'] },
    'related_resource' => { from: ['related_resource'] },
    'resource_type' => { from: ['resource_type'] },
    'rights_statement' => { from: ['rights_statement'] },
    'source' => { from: ['source'] },
    'subject' => { from: ['subject'] },
    'subtitle' => { from: ['subtitle'] },
    'title' => { from: ['title'] },
    'title_alternative' => { from: ['title_alternative'] },

    # Spot::InstitutionalMetadata mixin properites
    'academic_department' => { from: ['academic_department'] },
    'division' => { from: ['division'] },
    'organization' => { from: ['organization'] },

    # Publication properties
    'abstract' => { from: ['abstract'] },
    'bibliographic_citation' => { from: ['bibliographic_citation'] },
    'date_available' => { from: ['date_available'] },
    'date_issued' => { from: ['date_issued'] },
    'editor' => { from: ['editor'] },
    'license' => { from: ['license'] },

    # Image properties
    'date' => { from: ['date'] },
    'date_associated' => { from: ['date_associated'] },
    'date_scope_note' => { from: ['date_scope_note'] },
    'donor' => { from: ['donor'] },
    'inscription' => { from: ['inscription'] },
    'original_item_extent' => { from: ['original_item_extent'] },
    'repository_location' => { from: ['repository_location'] },
    'requested_by' => { from: ['requested_by'] },
    'research_assistance' => { from: ['research_assistance'] },
    'subject_ocm' => { from: ['subject_ocm'] },

    # StudentWork properties
    'access_note' => { from: ['access_note'] }
  }

  # Path to store pending imports
  # config.import_path = 'tmp/imports'

  # Path to store exports before download
  config.export_path = 'tmp/exports'

  # Server name for oai request header
  # config.server_name = 'my_server@name.com'

  # NOTE: Creating Collections using the collection_field_mapping will no longer be supported as of Bulkrax version 3.0.
  #       Please configure Bulkrax to use related_parents_field_mapping and related_children_field_mapping instead.
  # Field_mapping for establishing a collection relationship (FROM work TO collection)
  # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
  # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
  # The default value for CSV is collection
  # Add/replace parsers, for example:
  # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

  # Field mappings
  # Create a completely new set of mappings by replacing the whole set as follows
  #   config.field_mappings = {
  #     "Bulkrax::OaiDcParser" => { **individual field mappings go here*** }
  #   }

  # Add to, or change existing mappings as follows
  #   e.g. to exclude date
  #   config.field_mappings["Bulkrax::OaiDcParser"]["date"] = { from: ["date"], excluded: true  }
  #
  #   e.g. to import parent-child relationships
  #   config.field_mappings['Bulkrax::CsvParser']['parents'] = { from: ['parents'], related_parents_field_mapping: true }
  #   config.field_mappings['Bulkrax::CsvParser']['children'] = { from: ['children'], related_children_field_mapping: true }
  #   (For more info on importing relationships, see Bulkrax Wiki: https://github.com/samvera-labs/bulkrax/wiki/Configuring-Bulkrax#parent-child-relationship-field-mappings)
  #
  # #   e.g. to add the required source_identifier field
  #   #   config.field_mappings["Bulkrax::CsvParser"]["source_id"] = { from: ["old_source_id"], source_identifier: true  }
  # If you want Bulkrax to fill in source_identifiers for you, see below

  # To duplicate a set of mappings from one parser to another
  #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
  #   config.field_mappings["Bulkrax::OaiDcParser"].each {|key,value| config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value }

  # Should Bulkrax make up source identifiers for you? This allow round tripping
  # and download errored entries to still work, but does mean if you upload the
  # same source record in two different files you WILL get duplicates.
  # It is given two aruguments, self at the time of call and the index of the reocrd
  #    config.fill_in_blank_source_identifiers = ->(parser, index) { "b-#{parser.importer.id}-#{index}"}
  # or use a uuid
  #    config.fill_in_blank_source_identifiers = ->(parser, index) { SecureRandom.uuid }

  # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
  # config.reserved_properties += ['my_field']
end

# Sidebar for hyrax 3+ support
#
# Leaving out for now because this check was raising a NameError for Hyrax::SearchState
# in the db_migrate container for some reason, and since we're not on Hyrax 3 yet we
# already know the outcome of the check.
#
# Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
