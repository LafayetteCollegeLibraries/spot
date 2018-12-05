# frozen_string_literal: true
#
# Parses a BagIt directory and ingests the contents. This handles the messy
# business of getting the Darlingtonia pieces in order for ingestion.
#
# @example
#   path = '/path/to/ingestable/bag'
#   Spot::IngestBagJob.perform_later(bag_path, source: 'newspaper')
#
# Note: Rails can't handle symbol arguments, so be sure to convert your
#       source to a String! I _think_ this is fixed in Rails 6.
#       (see: https://github.com/rails/rails/issues/25993)
module Spot
  class IngestBagJob
    # Validates the Bag and imports if it's okay.
    #
    # @param [String, Pathname] bag_path Path to the Bag directory
    # @param [String] source: Source collection / which mapper to use
    # @return [void]
    # @raise [ValidationError] if the file to parse is invalid
    #   (from Darlingtonia::Parser)
    def perform(bag_path, source:)
      raise ArgumentError, "Unknown `source`: #{source}." unless source_available?(source)

      @bag_path = bag_path
      @source = source

      Rails.logger.debug "Ingesting bag [#{bag_path}] using #{source} mapper"

      importer.import if parser.validate!
    end

    private

    attr_reader :bag_path, :source

    # Does the provided symbol have a mapper associated with it?
    #
    # @param [String, Symbol] which
    # @return [Constant, nil]
    def source_available?(which)
      Spot::Mappers.available_mappers.include?(which.to_sym)
    end

    def mapper
      @mapper ||= Spot::Mappers.get(source.to_sym).new
    end

    def parser
      @parser ||= Spot::Importers::Bag::Parser.new(file: bag_path, mapper: mapper)
    end

    def record_importer
      @record_importer ||= Spot::Importers::Bag::RecordImporter.new(
                             info_stream: Rails.logger,
                             error_stream: Rails.logger
                           )
    end

    def importer
      @importer ||= Darlingtonia::Importer.new(parser: parser,
                                              record_importer: record_importer)
    end
  end
end
