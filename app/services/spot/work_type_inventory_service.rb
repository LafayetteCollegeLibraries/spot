# frozen_string_literal: true
module Spot
  # Service to produce CSV inventories of each WorkType model in the application.
  class WorkTypeInventoryService
    def self.call(work_types = Hyrax.config.curation_concerns)
      new(work_types).call
    end

    def initialize(work_types = Hyrax.config.curation_concerns)
      @work_types = Array.wrap(work_types)
    end

    def call
      write_files_to_zip(export_files)
    end

    private

    def audit_user
      @audit_user ||= Spot::SystemUserService.audit_user
    end

    def export_files
      work_type_exporters.map do |exporter|
        exporter.export # capture metadata
        exporter.save
        exporter.reload # need to reload to access #current_run and #parser

        next if exporter.current_run.total_work_entries.zero?

        exporter.parser.write_files # write the csv but don't zip it
        exporter.parser.setup_export_file # return the export file's name
      end.compact
    end

    def find_or_create_exporter_for(work_type)
      exporter = Bulkrax::Exporter.find_or_initialize_by(export_from: 'worktype',
                                                         export_type: 'metadata',
                                                         export_source: work_type.to_s,
                                                         parser_klass: 'Spot::CsvParser')
      return exporter unless exporter.new_record?

      exporter.name = "Work Type Inventory - #{work_type}"
      exporter.field_mapping = Bulkrax.field_mappings[exporter.parser_klass]
      exporter.user = audit_user
      exporter.save!
      exporter
    end

    # @todo make this configurable?
    def inventory_directory
      Rails.root.join('tmp', 'inventories')
    end

    # Since this is generating a name based on a potentially variable value, let's memoize it.
    # (Theoretically, we could create the directory, generate each file, and create the output
    # across midnight which would generate a different name on each call).
    #
    # @return [String] ldr-work_type_inventory-YYYYMMDD
    def inventory_filename
      @inventory_filename ||= "ldr-work_type_inventory-#{Time.zone.now.strftime('%Y%m%d')}"
    end

    # @return [Array<Bulkrax::Exporter>]
    def work_type_exporters
      @work_types.map { |work_type| find_or_create_exporter_for(work_type) }
    end

    # Writes the individual CSV inventories to a Zip file and returns the outputted filename.
    #
    # @param [Array<String>] files
    #   absolute paths to CSV inventories of each work_type (when a work_type has works)
    # @return [String]
    def write_files_to_zip(files)
      output_filename = File.join(inventory_directory, "#{inventory_filename}.zip")

      Dir.mktmpdir do |tmp|
        inventory_tmp = File.join(tmp, inventory_filename)
        FileUtils.mkdir_p(inventory_tmp)

        # copy each file to the tmp dir
        files.each { |file| FileUtils.cp(file, File.join(inventory_tmp, File.basename(file))) if File.exist?(file) }

        Spot::ZipService.new(src_path: inventory_tmp).zip!(dest_path: output_filename)
      end

      # cleanup existing inventory files
      files.each { |f| FileUtils.rm(f) }

      output_filename
    end
  end
end
