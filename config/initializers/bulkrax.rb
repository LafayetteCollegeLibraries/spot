# frozen_string_literal: true

Bulkrax.setup do |config|
  # Add local parsers
  config.parsers = [
    { name: 'CSV Parser', class_name: 'Spot::CsvParser', partial: 'csv_fields' },
  ]

  # WorkType to use as the default if none is specified in the import
  # Default is the first returned by Hyrax.config.curation_concerns
  config.default_work_type = Hyrax.config.curation_concerns.first

  # Path to store pending imports
  config.import_path = 'tmp/imports'

  # Path to store exports before download
  config.export_path = 'tmp/exports'

  # We only use bars for split/join operations
  config.multi_value_element_split_on = /|/
  config.multi_value_element_join_on = '|'

  # Server name for oai request header
  # config.server_name = 'my_server@name.com'

  # Update the default_field_mapping to split by default
  config.default_field_mapping = lambda do |field|
    return if field.blank?

    {
      field.to_s => {
        from: [field.to_s],
        split: true,
        parsed: Bulkrax::ApplicationMatcher.method_defined?("parse_#{field}"),
        if: nil,
        excluded: false,
      }
    }
  end

  # Similarly to our `Spot::SolrDocumentAttributes` mixin, the parsers need
  # to be aware of every metadata field we'd like to include across all models
  # and mixins. As exporters sort these fields alphabetically, and
  # `CsvEntry#build_mapping_metadata` will skip fields the model doesn't respond_to,
  # the order doesn't really matter. I'll be following the order/convention set
  # by the SolrDocument mixin.
  #
  # @see https://github.com/samvera-labs/bulkrax/blob/v2.0.0/app/models/bulkrax/csv_entry.rb#L120
  config.field_mappings['Spot::CsvParser'] = {
    # Hyrax properties
    'date_uploaded' => { from: ['date_uploaded'] },
    'work_type' => { from: ['model', 'work_type'] },

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
    # (a good chunk are across the other models)
    'access_note' => { from: ['access_note'] }
  }

  config.fill_in_blank_source_identifiers = ->(entry, index) { "import:#{entry.importerexporter.id}-#{index + 1}" }

  # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
  # config.reserved_properties += ['my_field']

  # List of Questioning Authority properties that are controlled via YAML files in
  # the config/authorities/ directory. For example, the :rights_statement property
  # is controlled by the active terms in config/authorities/rights_statements.yml
  # Defaults: 'rights_statement' and 'license'
  # config.qa_controlled_properties += ['my_field']
end

# Sidebar for hyrax 3+ support
Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
