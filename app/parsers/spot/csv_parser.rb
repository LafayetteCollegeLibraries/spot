# frozen_string_literal: true
module Spot
  class CsvParser < ::Bulkrax::CsvParser
    # Just for now
    #
    # @return [false]
    def self.import_supported?
      false
    end

    def entry_class
      ::Spot::CsvEntry
    end

    # Does the same thing as Bulkrax::CsvParser but downcases the file name.
    #
    # @see https://github.com/samvera-labs/bulkrax/blob/v2.0.1/app/parsers/bulkrax/csv_parser.rb#L265-L268
    def setup_export_file
      File.join(importerexporter.exporter_export_path, "export_#{importerexporter.export_source}_from_#{importerexporter.export_from}.csv".downcase)
    end
  end
end
