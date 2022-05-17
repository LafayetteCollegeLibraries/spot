# frozen_string_literal: true
module Spot
  class CSVIngestService
    def self.perform(file:,
                     source_path:,
                     work_type: nil,
                     collection_ids: [],
                     admin_set_id: Spot::Importers::CSV::RecordImporter.default_admin_set_id)
      new(file: file,
          source_path: source_path,
          work_type: work_type,
          collection_ids: collection_ids,
          admin_set_id: admin_set_id).perform
    end

    def initialize(file:,
                   source_path:,
                   work_type: nil,
                   collection_ids: [],
                   admin_set_id: Spot::Importers::CSV::RecordImporter.default_admin_set_id)
      @file = file
      @source_path = source_path
      @work_type = work_type
      @collection_ids = collection_ids
      @admin_set_id = admin_set_id
    end

    def perform
      importer.import if parser.validate!
    end

    def importer
      Darlingtonia::Importer.new(parser: parser, record_importer: record_importer)
    end

    def parser
      @parser ||= Spot::Importers::CSV::Parser.new(file: @file, work_type: @work_type)
    end

    def record_importer
      Spot::Importers::CSV::RecordImporter.new(source_path: @source_path,
                                               collection_ids: @collection_ids,
                                               admin_set_id: @admin_set_id)
    end
  end
end
