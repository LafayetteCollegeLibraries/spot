# frozen_string_literal: true
module Spot
  class ExportController < ApplicationController
    attr_reader :solr_document

    before_action :load_and_authorize_resource

    def show
      # Hyrax::DownloadsController is already equipped to handle downloading
      # file_sets, so just forward those requests there (note: I'm not expecting
      # that to happen, but you never know)
      redirect_to hyrax.download_path(solr_document) and return if wants_file_set?

      send_file(exported_work, filename: "#{solr_document.id}.zip")
    end

    private

      # I think in the future this could/should be moved to something offsite
      # (read: more available storage) like S3. For now, we'll store it in 'tmp/'
      # and have Capistrano ensure that it a) exists and b) is shared between
      # deployments. We'll have to manually clean it out
      #
      # @return [Pathname]
      def cache_directory
        Rails.root.join('tmp', 'export')
      end

      # @return [Pathname]
      def cache_path
        cache_directory.join("#{solr_document.id}-#{solr_document['_version_']}.zip")
      end

      # @return [void]
      def export_work_to_cache
        exporter.export!(destination: cache_path)
      end

      # @return [Pathname]
      def exported_work
        export_work_to_cache unless File.exist?(cache_path)
        cache_path
      end

      # @return [Spot::Exporters::ZippedWorkExporter]
      def exporter
        Spot::Exporters::ZippedWorkExporter.new(solr_document, current_ability, request)
      end

      # @return [SolrDocument]
      # @todo Actually authorize the resource!
      def load_and_authorize_resource
        @solr_document = ::SolrDocument.find(params[:id])
      end

      # @return [true, false]
      def wants_file_set?
        solr_document.hydra_model == FileSet
      end
  end
end
