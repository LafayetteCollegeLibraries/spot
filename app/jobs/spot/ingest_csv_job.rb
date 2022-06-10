# frozen_string_literal: true
module Spot
  class IngestCSVJob < ::ApplicationJob
    def perform(metadata_path:, source_path:, work_type: nil, collection_ids: [],
                admin_set_id: Spot::Importers::CSV::RecordImporter.default_admin_set_id)
      Spot::CSVIngestService.perform(file: File.open(metadata_path, 'r'),
                                     source_path: source_path,
                                     admin_set_id: admin_set_id,
                                     collection_ids: collection_ids,
                                     work_type: work_type)
    end
  end
end
