# frozen_string_literal: true
module Spot
  # Mixin to add to remove FileSets from Bulkrax Exports.
  #
  # This should be `.prepend` ed into the Bulkrax::CsvParser class
  # in an initializer.
  #
  # @example
  #   Bulkrax::CsvParser.prepend(Spot::SpotCsvParser)
  #
  module SpotCsvParser
    extend ActiveSupport::Concern
    def create_new_entries
      # NOTE: The each method enforces the limit, as it can best optimize the underlying queries.
      current_records_for_export.each do |id, entry_class|
        next if entry_class == file_set_entry_class
        new_entry = find_or_create_entry(entry_class, id, 'Bulkrax::Exporter')
        begin
          entry = ExportWorkJob.perform_now(new_entry.id, current_run.id)
        rescue => e
          Rails.logger.info("#{e.message} was detected during export")
        end

        self.headers |= entry.parsed_metadata.keys if entry
      end
    end
  end
end