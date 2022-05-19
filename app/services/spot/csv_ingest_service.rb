# frozen_string_literal: true
module Spot
  # Service for creating works from CSV files. This wraps up the individual pieces
  # of Digital Curation Expert's (now deprecated) Darlingtonia gem and simplifies
  # things by providing a single interface to use.
  #
  # Ingesting works using this service requires a) a metadata CSV file with fields
  # matching metadata properties of a Spot work type, b) a directory of files to
  # attach to works, with the metadata CSV file referencing the relative names in
  # a "file" field.
  #
  # As Darlingtonia is deprecated, this service is acting as a bridge from our
  # homespun migration ingest infrastructure to a more robust one using a third-party
  # community gem such as Bulkrax or Zizia.
  #
  # ## Metadata CSV
  #
  # CSV files to be used require a "file" field which specifies the path, relative
  # to the "source_path" used as a root directory, of the file to attach to the
  # created work. So a value of "files/object.tif" and a source_path of "/var/www/spot/ingest"
  # will ingest the file found at "/var/www/spot/ingest/files/object.tif".
  #
  # Optionally, CSV files may also have a "work_type" field to specify the type of
  # object to create. This is intended to be a string that, when passed through
  # `String#camelize` and `String#constantize` will result in a valid Hyrax work
  # Class. Examples include "image", "Publication", "student_work", or "StudentWork"
  #
  # Other fields are expected to map to the work_type provided in the CSV row or
  # passed into this service. Header keys should match their property definition
  # in Spot in case (lower), spacing (replace spaces with underlines;
  # eg. `"date issued".gsub(/\s/, "_")`), and name ("title_alternative" not "alternative_title").
  # Hyrax/Fedora internal metadata fields are skipped (see
  # {Spot::Mappers::WorkTypeMapper::EXCLUDED_PROPERTIES} array).
  #
  # @example General Usage
  #   # given a file path that looks like:
  #   #   /path/to/new_objects
  #   #   /path/to/new_objects/metadata.csv
  #   #   /path/to/new_objects/files
  #   #   /path/to/new_objects/files/object_1.tif
  #
  #   ingest_path = '/path/to/new_objects'
  #   file = File.open(File.join(ingest_path, 'metadata.csv'), 'r')
  #   source_path = File.join(ingest_path, 'files')
  #
  #   Spot::CSVIngestService.perform(file: file, source_path: source_path)
  #
  # @see {Spot::Importers::CSV::Parser}
  # @see {Spot::Importers::CSV::RecordImporter}
  class CSVIngestService
    # @param [Hash] options
    # @option [IO] file
    # @option [String,Pathname] source_path
    # @option [String,Symbol] work_type
    # @option [Array<String>] collection_ids
    # @option [String] admin_set_id
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

    # @return [void]
    # @raise [Darlingtonia::ValidationError]
    # @see https://github.com/curationexperts-deprecated/darlingtonia/blob/v3.2.2/lib/darlingtonia/parser.rb#L121-L127
    def perform
      importer.import if parser.validate!
    end

    # @see https://github.com/curationexperts-deprecated/darlingtonia/blob/v3.2.2/lib/darlingtonia/importer.rb
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
