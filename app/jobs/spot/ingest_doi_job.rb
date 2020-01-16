# frozen_string_literal: true
module Spot
  class IngestDOIJob < ::ApplicationJob
    queue_as :ingest

    def perform(doi:, work_class:, collection_ids: [])
      @doi = doi
      @work_class = work_class.constantize
      @collection_ids = collection_ids

      raise ArgumentError, "Unknown work_class: #{@work_class}" unless work_class_valid?

      logger.debug "Ingesting DOI [#{@doi}] from unpaywall.org"
      importer.import if parser.validate!
    end

    private

      # @return [Darlingtonia::Importer]
      def importer
        @importer ||= Darlingtonia::Importer.new(parser: parser,
                                                 record_importer: record_importer)
      end

      # @return [Spot::Importers::Unpaywall::Parser]
      def parser
        @parser ||= ::Spot::Importers::Unpaywall::Parser.new(doi: @doi)
      end

      # @return [Spot::Importers::Bag::RecordImporter]
      def record_importer
        @record_importer ||= begin
          info = Spot::StreamLogger.new(logger, level: ::Logger::INFO)
          error = Spot::StreamLogger.new(logger, level: ::Logger::WARN)
          Spot::Importers::Unpaywall::RecordImporter.new(work_klass: @work_class,
                                                         collection_ids: @collection_ids,
                                                         info_stream: info,
                                                         error_stream: error)
        end
      end

      # Is the work_class provided one of our curation_concerns?
      #
      # @return [true, false]
      def work_class_valid?
        ::Hyrax.config.curation_concerns.include?(@work_class)
      end
  end
end
