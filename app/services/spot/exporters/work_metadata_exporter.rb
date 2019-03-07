# frozen_string_literal: true
#
# Exports a work's metadata to files. I'm not very stoked on this implementation;
# I'd rather just pass the work and use +Hyrax::GraphExporter+ to generate an RDF
# graph and use +graph.dump(format)+, however this somehow ties up the Fedora connection
# more than using Hyrax's presenters (which uses the same thing?). Again, truly miffed
# about this.
module Spot
  module Exporters
    class WorkMetadataExporter
      attr_reader :solr_document, :ability, :request

      # @param [SolrDocument]
      # @param [Ability, nil]
      # @param [#host]
      def initialize(solr_document, ability = nil, request = nil)
        @solr_document = solr_document
        @ability = ability
        @request = request
      end

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
          when :nt then presenter.export_as_nt
          when :ttl then presenter.export_as_ttl
          when :jsonld then presenter.export_as_jsonld
          else nil
          end
        end

        # @return [Hyrax::WorkShowPresenter]
        def presenter
          presenter_for_solr_document.new(solr_document, ability, request)
        end

        # @return [Class]
        def presenter_for_solr_document
          Hyrax.const_get("#{solr_document.hydra_model}Presenter")
        end
    end
  end
end
