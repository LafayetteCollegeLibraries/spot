# frozen_string_literal: true
module Spot
  class ExportController < ApplicationController
    include Blacklight::Base
    include Blacklight::AccessControls::Catalog

    class_attribute :search_builder_class
    self.search_builder_class = Hyrax::WorkSearchBuilder

    attr_reader :solr_document

    before_action :load_and_authorize_resource

    def show
      redirect_to hyrax.download_path(solr_document.id) and return if wants_file_set?

      file_sets = solr_document.file_set_ids
      redirect_to hyrax.download_path(file_sets.first) and return if wants_only_file_set?

      # for some reason, we need to reset the Fedora connection before
      # we can run an export of the members + metadata. my best guess is
      # that number of requests in a short amount of time is too much
      # for the ActiveFedora's connection to handle? I'm really unsure
      # about it, but this at least lets us get an export happening.
      ActiveFedora::Fedora.reset!

      send_file(export_work_to_cache!, filename: "#{solr_document.id}.zip")
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

      # @return [Pathname]
      def export_work_to_cache!
        exporter.export!(destination: cache_path) unless File.exist?(cache_path)
        cache_path
      end

      # @return [Spot::Exporters::ZippedWorkExporter]
      def exporter
        Spot::Exporters::ZippedWorkExporter.new(solr_document, request)
      end

      # Sets the @solr_document attribute from a single-item solr query.
      # Getting the work this way (rather than calling +ActiveFedora::Base+)
      # allows us to leverage the Hyrax permissions via Solr query and
      # saves us the hassle of writing that logic ourselves. The downside
      # is that we need to query the work
      #
      # @return [void]
      # @raises WorkflowAuthorizationException if user can read but the doc is suppressed
      # @raises CanCan::AccessDenied
      def load_and_authorize_resource
        search_params = params
        search_params.delete :page
        search_params.delete :type

        _, doc_list = search_results(search_params)
        @solr_document = doc_list.first unless doc_list.empty?

        return unless @solr_document.nil?

        doc = SolrDocument.find(params[:id])
        raise WorkflowAuthorizationException if doc.suppressed? && current_ability.can?(:read, doc)
        raise CanCan::AccessDenied.new(nil, :show)
      end

      # @return [true, false]
      def wants_file_set?
        solr_document.hydra_model == FileSet
      end

      # Do we only want the files of a work that only has one file?
      #
      # @return [true, false]
      def wants_only_file_set?
        solr_document.file_set_ids.size == 1 && params[:export_type] == 'files'
      end
  end
end
