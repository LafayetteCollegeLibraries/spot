# frozen_string_literal: true
require 'tmpdir'
require 'fileutils'

module Spot
  module Exporters
    class ZippedWorkExporter
      attr_reader :work, :ability, :request

      # @param [ActiveFedora::Base]
      # @param [Ability]
      # @param [ActionDispatch::Request]
      def initialize(work, ability, request)
        @work = work
        @ability = ability
        @request = request
      end

      # @param [Pathname, String] :destination
      # @param [Symbol] :metadata_formats The formats we're looking to export.
      #   See {Spot::Exporters::WorkMetadataExporter#export!}
      def export!(destination:, metadata_formats: :all)
        @metadata_formats = metadata_formats

        in_working_directory do
          export_metadata!(metadata_formats) if include_metadata?
          export_members!
          zip_export_to(destination)
        end
      end

      private
        attr_reader :tmpdir

        # @return [void]
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
          WorkMembersExporter.new(work)
        end

        # @return [Spot::Exporters::WorkMetadataExporter]
        def metadata_exporter
          WorkMetadataExporter.new(solr_document, ability, request)
        end

        # @return [SolrDocument]
        def solr_document
          @solr_document ||= SolrDocument.find(work.id)
        end

        def zip_export_to(destination)
          ::ZipService.new(src_path: tmpdir)
                      .zip!(dest_path: destination)
        end
    end
  end
end
