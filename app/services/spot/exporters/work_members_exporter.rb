# frozen_string_literal: true
#
# Exporter that writes all of a work's associated files to a destination.
module Spot
  module Exporters
    class WorkMembersExporter
      attr_reader :work

      # @param [ActiveFedora::Base] work
      def initialize(work)
        @work = work
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

      # @return [Array<Hydra::PCDM::File>]
      def files
        work.file_sets.map(&:original_file)
      end
    end
  end
end
