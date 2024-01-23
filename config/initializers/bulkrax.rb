# frozen_string_literal: true
Bulkrax.setup do |config|
  config.default_work_type = Hyrax.config.curation_concerns.first

  # Called when importing if no source_identifier found in the metadata
  config.fill_in_blank_source_identifiers = ->(obj, index) { "#{obj.importerexporter.name}-#{obj.importerexporter.id}-#{index}" }

  config.parsers = [
    { name: 'CSV - Comma Separated Values', class_name: 'Bulkrax::CsvParser', partial: 'csv_fields' }
  ]

  # Store our imports alongside uploads
  config.import_path = Rails.root.join('tmp', 'uploads', 'bulkrax', 'imports')
  config.export_path = Rails.root.join('tmp', 'uploads', 'bulkrax', 'exports')

  # Updates the default_field_mapping to default to splitting and joining with bars (|).
  # Because the :split value is cast to a Regexp, the bar character needs to be escaped,
  # otherwise the value will be split on each character.
  #
  # @see https://github.com/samvera/bulkrax/blob/v5.4.0/lib/bulkrax.rb#L187-L200
  # @see https://github.com/samvera/bulkrax/blob/v5.4.0/app/matchers/bulkrax/application_matcher.rb#L40
  config.default_field_mapping = lambda do |field|
    return if field.blank?
    {
      field.to_s => {
        from: [field.to_s],
        split: '\|',
        parsed: Bulkrax::ApplicationMatcher.method_defined?("parse_#{field}"),
        if: nil,
        excluded: false
      }
    }
  end

  # @see https://github.com/samvera/bulkrax/wiki/Configuring-Bulkrax#field-mappings
  config.field_mappings = {
    'Bulkrax::CsvParser' => {
      'source_identifier' => { from: ['source_identifier'], source_identifier: true, split: false, join: false },
      'model' => { from: ['model', 'work_type'], split: false },

      # Descriptive metadata
      'title' => { from: ['title'] },
      'title_alternative' => { from: ['title_alternative'] },
      'subtitle' => { from: ['subtitle'] },
      'creator' => { from: ['creator'] },
      'contributor' => { from: ['contributor'] },
      'editor' => { from: ['editor'] },
      'abstract' => { from: ['abstract'] },
      'description' => { from: ['description'] },
      'inscription' => { from: ['inscription'] },
      'bibliographic_citation' => { from: ['bibliographic_citation'] },
      'identifier' => { from: ['identifier'], parsed: false },
      'keyword' => { from: ['keyword'] },
      'language' => { from: ['language'] },
      'license' => { from: ['license'] },
      'location' => { from: ['location'] },
      'note' => { from: ['note'] },
      'physical_medium' => { from: ['physical_medium'] },
      'publisher' => { from: ['publisher'] },
      'related_resource' => { from: ['related_resource'] },
      'resource_type' => { from: ['resource_type'] },
      'rights_holder' => { from: ['rights_holder'] },
      'rights_statement' => { from: ['rights_statement'], parsed: false },
      'source' => { from: ['source'] },
      'subject' => { from: ['subject'], parsed: false },
      'subject_ocm' => { from: ['subject_ocm'] },

      # Date fields
      'date' => { from: ['date'] },
      'date_associated' => { from: ['date_associated'] },
      'date_available' => { from: ['date_available'] },
      'date_issued' => { from: ['date_issued'] },
      'date_scope_note' => { from: ['date_scope_note'] },

      # Institutional metadata
      'academic_department' => { from: ['academic_department'] },
      'division' => { from: ['division'] },
      'organization' => { from: ['organization'] },

      # Staff-side metadata
      'access_note' => { from: ['access_note'] },
      'donor' => { from: ['donor'] },
      'local_identifier' => { from: ['local_identifier'] },
      'original_item_extent' => { from: ['original_item_extent'] },
      'repository_location' => { from: ['repository_location'] },
      'requested_by' => { from: ['requested_by'] },
      'research_assistance' => { from: ['research_assistance'] },
      'sponsor' => { from: ['sponsor'] },
      'standard_identifier' => { from: ['standard_identifier'] },

      # Generated properties, these are excluded from exports unless requested
      'admin_set_id' => { from: ['admin_set_id'], generated: true },
      'date_modified' => { from: ['date_modified'], generated: true },
      'date_uploaded' => { from: ['date_uploaded'], generated: true },
      'depositor' => { from: ['depositor'], generated: true },
      'file_size' => { from: ['file_size'], generated: true },
      'original_checksum' => { from: ['original_checksum'], generated: true },
      'page_count' => { from: ['page_count'], generated: true },
      'permalink' => { from: ['permalink'], generated: true },

      # relationship data
      'collection_slug' => { from: ['collection_slug'] },
      'children' => { from: ['children'], related_children_field_mapping: true },
      'parents' => { from: ['parents'], related_parents_field_mapping: true }
    }
  }
end

# Modify ExportBehavior to _not_ include the file_set ID as part of the file name
# @see https://github.com/samvera/bulkrax/blob/v5.4.1/app/models/concerns/bulkrax/export_behavior.rb#L28-L44
Rails.application.config.to_prepare do
  Bulkrax::ExportBehavior.class_eval do
    def filename(file_set)
      original_file = file_set.original_file
      return if original_file.blank?

      name = original_file.file_name.first
      return name if name.length < 256

      basename = File.basename(name, '.*')
      ext = File.extname(name)

      "#{basename[0...(255 - ext.length)]}#{ext}"
    end
  end
end
