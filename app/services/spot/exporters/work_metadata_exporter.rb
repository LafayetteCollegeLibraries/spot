# frozen_string_literal: true
module Spot
  module Exporters
    class WorkMetadataExporter
      attr_reader :solr_document, :request

      # @param [SolrDocument]
      # @param [Ability, nil]
      # @param [#host]
      def initialize(solr_document, request = nil)
        @solr_document = solr_document
        @request = request
      end

      # @param [Pathname, String] :destination
      #   Where to export the files
      # @param [Symbol] :format
      #   Format of exported metadata. Accepts:
      #     - :all (all formats)
      #     - :nt (ntriples)
      #     - :ttl (turtle)
      #     - :jsonld (json linked-data)
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
          %i[nt ttl jsonld]
        end

        # @param [Symbol] format
        # @return [String, nil]
        def export_for_format(format)
          case format
          when :nt then graph.dump(:ntriples)
          when :ttl then graph.dump(:ttl)
          when :jsonld then graph.dump(:jsonld, standard_prefixes: true)
          end
        end

        # @return [RDF::Graph]
        def graph
          @graph ||= Hyrax::GraphExporter.new(solr_document, request).fetch
        end
    end
  end
end
