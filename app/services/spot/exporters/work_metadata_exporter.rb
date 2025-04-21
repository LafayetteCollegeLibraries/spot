# frozen_string_literal: true
module Spot
  module Exporters
    # Service to, well, export the metadata of a work. Requires a SolrDocument and an
    # ActionDispatch::Request object to substitute out the local Fedora hostname with
    # the site's (this is expected to be called from within a Controller context, see todo).
    # Note that this is only used for Linked Data exports (:nt, :ttl, :jsonld) and not
    # for :csv files.
    #
    # Supports the following Symbols for export formats:
    #  - :csv (comma-separated values)
    #  - :jsonld (json linked-data)
    #  - :nt (ntriples)
    #  - :ttl (turtle)
    #  - :all (all formats)
    #
    # @example
    #   solr_document = SolrDocument.find(id)
    #   export_destination = Rails.root.join('tmp', 'metadata_exports')
    #   FileUtils.mkdir_p(export_destination) unless Dir.exist?(export_destination)
    #   Spot::WorkMetadataExporter.new(solr_document).export!(destination: export_destination, format: :csv)
    #
    # @todo Hyrax::GraphExporter no longer requires a `request` parameter and now prefers a :hostname keyword param.
    #       We can substitute out "request" and use something like `ENV['APPLICATION_FQDN']` or
    #       `URI.parse(ENV['SITE_URL']).hostname` instead to make this independent of the controller context.
    class WorkMetadataExporter
      attr_reader :solr_document, :request

      # @param [SolrDocument]
      # @param [ActionDispatch::Request, #host, nil]
      # @param [#host]
      def initialize(solr_document)
        @solr_document = solr_document
      end

      # @param [Pathname, String] :destination
      #   Where to export the files
      # @param [Symbol] :format
      # @return [void]
      def export!(destination:, format: :all)
        format = all_formats if format == :all

        Array.wrap(format).each do |f|
          metadata = export_for_format(f)
          next if metadata.nil? # unsupported format

          out_path = File.join(destination, "#{solr_document.id}.#{f}")

          File.open(out_path, 'w') { |io| io.write metadata }
        end
      end

      private

      # @return [Array<Symbol>]
      def all_formats
        %i[nt ttl jsonld csv]
      end

      # @param [Symbol] format
      # @return [String, nil]
      def export_for_format(format)
        case format
        when :nt then graph.dump(:ntriples)
        when :ttl then graph.dump(:ttl)
        when :jsonld then graph.dump(:jsonld, standard_prefixes: true)
        when :csv then generate_csv_content
        end
      end

      # @return [String]
      def generate_csv_content
        Spot::WorkCsvService.new(solr_document).csv
      end

      # @return [RDF::Graph]
      def graph
        @graph ||= graph_exporter.fetch
      end

      def graph_exporter
        Hyrax::GraphExporter.new(solr_document, hostname: URI.parse(ENV.fetch('URL_HOST')).hostname)
      end
    end
  end
end
