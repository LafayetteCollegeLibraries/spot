# frozen_string_literal: true
module Spot
  class BagIngestService
    def initialize(bag_path:, mapper_klass:, work_klass:, collection_ids: [], multi_value_character: '|')
      @bag_path = bag_path
      @mapper_klass = mapper_klass
      @work_klass = work_klass
      @collection_ids = collection_ids
      @multi_value_character = multi_value_character
    end

    def ingest
      validate_arguments!
      parser.validate!

      logger.debug "Ingesting bag [#{bag_path}] using #{source} mapper"
      importer.import if parser.validate!
    end

    private

      attr_reader :bag_path, :source

      def validate_arguments!
        raise ArgumentError, "Unknown source: #{source}." unless source_available?
        raise ArgumentError, "Unknown work_class: #{work_class}" unless work_class_valid?
      end

      # Is the work_class provided one of our curation_concerns?
      #
      # @return [TrueClass, FalseClass]
      def work_class_valid?
        ::Hyrax.config.curation_concerns.include?(@work_class)
      end

      # Does the provided symbol have a mapper associated with it?
      #
      # @return [Constant, nil]
      def source_available?
        Spot::Mappers.available_mappers.include?(@source.to_sym)
      end

      # The mapper to use, decided by the +:source+ parameter
      #
      # @return [Darlingtonia::MetadataMapper]
      def mapper
        @mapper ||= @mapper_klass.new
      end

      # @return [Spot::Importers::Bag::Parser]
      def parser
        @parser ||=
          Spot::Importers::Bag::Parser.new(directory: bag_path,
                                           mapper: mapper,
                                           multi_value_character: @multi_value_character)
      end

      # @return [Spot::Importers::Bag::RecordImporter]
      def record_importer
        @record_importer ||= begin
          info = Spot::StreamLogger.new(logger, level: ::Logger::INFO)
          error = Spot::StreamLogger.new(logger, level: ::Logger::WARN)
          Spot::Importers::Bag::RecordImporter.new(work_klass: @work_klass,
                                                   collection_ids: @collection_ids,
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
