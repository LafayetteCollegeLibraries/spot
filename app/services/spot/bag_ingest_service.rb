# frozen_string_literal: true
module Spot
  class BagIngestService
    attr_reader :path, :mapper_klass, :work_klass, :collection_ids, :logger

    def initialize(path:, mapper_klass:, work_klass:,
                   collection_ids: [], logger: Rails.logger)
      @path = path
      @mapper_klass = mapper_klass
      @work_klass = work_klass
      @collection_ids = collection_ids
      @multi_value_character = multi_value_character
      @logger = logger
    end

    def ingest
      raise ArgumentError, "Unknown work_klass: #{work_klass}" unless work_klass_valid?

      logger.debug "Ingesting bag [#{path}] using #{mapper_klass}"
      importer.import if parser.validate!
    end

  private

    # Is the work_class provided one of our curation_concerns?
    #
    # @return [TrueClass, FalseClass]
    def work_klass_valid?
      ::Hyrax.config.curation_concerns.include?(work_klass)
    end

    def multi_value_character
      '|'
    end

    # @return [Spot::Importers::Bag::Parser]
    def parser
      @parser ||=
        Spot::Importers::Bag::Parser.new(directory: path,
                                         mapper: mapper_klass.new,
                                         multi_value_character: multi_value_character)
    end

    # @return [Spot::Importers::Bag::RecordImporter]
    def record_importer
      @record_importer ||= begin
        info = Spot::StreamLogger.new(logger, level: ::Logger::INFO)
        error = Spot::StreamLogger.new(logger, level: ::Logger::WARN)
        Spot::Importers::Bag::RecordImporter.new(work_klass: work_klass,
                                                 collection_ids: collection_ids,
                                                 info_stream: info,
                                                 error_stream: error)
      end
    end

    # @return [Darlingtonia::Importer]
    def importer
      @importer ||=
        Darlingtonia::Importer.new(parser: parser, record_importer: record_importer)
    end
  end
end
