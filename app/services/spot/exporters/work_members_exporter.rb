# frozen_string_literal: true
#
# This name _might_ be misleading, I'm not 100% sure. For now, we're only
# exporting a work's FileSets with this. Our parity release doesn't nest works,
# but works can have multiple FileSets.
module Spot
  module Exporters
    class WorkMembersExporter
      attr_reader :solr_document

      # @param [SolrDocument] solr_document
      def initialize(solr_document)
        @solr_document = solr_document
      end

      # Writes each Hydra::PCDM::File of a work to the provided destination
      #
      # @param [Pathname, String] :destination
      # @return [void]
      def export!(destination:)
        files.each do |file|
          File.open(File.join(destination, file.file_name.first), 'wb') do |io|
            file.stream.each { |chunk| io.write(chunk) }
          end
        end
      end

      # @todo How do we export members that are themselves works?
      # @return [Array<FileSet>]
      def file_sets
        @file_sets ||= ActiveFedora::Base.find(solr_document.file_set_ids)
                                         .select { |fs| fs.is_a? FileSet }
      end

      # Selects all items that the current user can download.
      #
      # @return [Array<Hydra::PCDM::File>]
      def files
        file_sets.map(&:original_file)
      end
    end
  end
end
