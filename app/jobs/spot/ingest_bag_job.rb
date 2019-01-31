# frozen_string_literal: true
#
# Parses a BagIt directory and ingests the contents. This handles the messy
# business of getting the Darlingtonia pieces in order for ingestion.
#
# @example
#   path = '/path/to/ingestable/bag'
#   Spot::IngestBagJob.perform_later(bag_path, source: 'newspaper', work_class: 'Publication')
#
# Note: Rails can't handle symbol arguments, so be sure to convert your
#       source to a String! I _think_ this is fixed in Rails 6.
#       (see: https://github.com/rails/rails/issues/25993)
module Spot
  class IngestBagJob < ::ApplicationJob
    # Validates the Bag and imports if it's okay.
    #
    # @param [String, Pathname] bag_path Path to the Bag directory
    # @param [String] source Source collection / which mapper to use
    # @param [String] work_class Work Type to use for new object
    # @return [void]
    # @raise [ArgumentError] if +source:+ is not defined in {Spot::Mappers.available_mappers}
    # @raise [ArgumentError] if +work_class:+ not a valid Work type
    # @raise [ValidationError] if the file to parse is invalid
    #   (from Darlingtonia::Parser)
    def perform(bag_path:, source:, work_class:)
      @bag_path = bag_path
      @source = source
      @work_class = work_class.constantize

      raise ArgumentError, "Unknown source: #{source}." unless source_available?
      raise ArgumentError, "Unknown work_class: #{work_class}" unless work_class_valid?

      logger.debug "Ingesting bag [#{bag_path}] using #{source} mapper"
      importer.import if parser.validate!
    end

    private

      attr_reader :bag_path, :source

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
        @mapper ||= Spot::Mappers.get(source.to_sym).new
      end

      # @return [Spot::Importers::Bag::Parser]
      def parser
        @parser ||= Spot::Importers::Bag::Parser.new(directory: bag_path,
                                                     mapper: mapper)
      end

      # @return [Spot::Importers::Bag::RecordImporter]
      def record_importer
        @record_importer ||= begin
          info = Spot::StreamLogger.new(logger, level: ::Logger::INFO)
          error = Spot::StreamLogger.new(logger, level: ::Logger::WARN)
          Spot::Importers::Bag::RecordImporter.new(work_class: @work_class,
                                                   info_stream: info,
                                                   error_stream: error)
        end
      end

      # @return [Darlingtonia::Importer]
      def importer
        @importer ||= Darlingtonia::Importer.new(parser: parser,
                                                 record_importer: record_importer)
      end
  end
end
