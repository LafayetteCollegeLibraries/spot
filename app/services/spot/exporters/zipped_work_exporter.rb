# frozen_string_literal: true
require 'tmpdir'
require 'fileutils'

module Spot
  module Exporters
    class ZippedWorkExporter
      attr_reader :solr_document, :ability, :request

      def initialize(solr_document, ability, request)
        @solr_document = solr_document
        @ability = ability
        @request = request
      end

      def export!(destination:, metadata_formats: :all)
        @metadata_formats = metadata_formats

        in_working_directory do
          unless metadata_formats.nil?
            export_metadata!(metadata_formats) if include_metadata?

            # for some reason, we need to reset the Fedora connection after
            # exporting the metadata or the members (one or the other).
            # note: this only happens when being called from a controller;
            # I'm able to get this working fine from the command line.
            # I am truly miffed!
            ActiveFedora::Fedora.reset!
          end

          export_members!
          zip_export_to(destination)
        end
      end

      private
        attr_reader :tmpdir

        def export_members!
          files_path = tmpdir
          files_path = File.join(files_path, 'files') if include_metadata?
          FileUtils.mkdir_p(files_path) unless Dir.exist?(files_path)

          members_exporter.export!(destination: files_path)
        end

        # @param [Symbol] :format what format we want our exports to be
        # @return [void]
        def export_metadata!(format)
          metadata_exporter.export!(destination: tmpdir, format: format)
        end

        # @return [true, false]
        def include_metadata?
          !@metadata_formats.nil?
        end

        # Wraps our operations in a +Dir.mktmpdir+ block so we don't
        # have to remember to delete the tmpdir when we're finished.
        #
        # @return [void]
        # @yields
        def in_working_directory
          Dir.mktmpdir do |tmpdir|
            @tmpdir = tmpdir
            yield
          end
        end

        # @return [Spot::Exporters::WorkMembersExporter]
        def members_exporter
          WorkMembersExporter.new(solr_document)
        end

        # @return [Spot::Exporters::WorkMetadataExporter]
        def metadata_exporter
          WorkMetadataExporter.new(solr_document, ability, request)
        end

        def zip_export_to(destination)
          ::ZipService.new(src_path: tmpdir)
                      .zip!(dest_path: destination)
        end
    end
  end
end
