# frozen_string_literal: true
module Spot
  class ExportController < ApplicationController
    attr_reader :work

    before_action :load_and_authorize_resource

    def show
      # Hyrax::DownloadsController is already equipped to handle downloading
      # file_sets, so just forward those requests there (note: I'm not expecting
      # that to happen, but you never know)
      redirect_to hyrax.download_path(work) and return if wants_file_set?

      # for some reason, we need to reset the Fedora connection before
      # we can run an export of the members + metadata. my best guess is
      # that number of requests in a short amount of time is too much
      # for the repository to handle? I'm really unsure about it,
      # but this at least lets us get an export happening.
      ActiveFedora::Fedora.reset!

      send_file(exported_work, filename: "#{work.id}.zip")
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
        cache_directory.join("#{work.id}-#{work.etag[3..-2]}.zip")
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
        Spot::Exporters::ZippedWorkExporter.new(work, current_ability, request)
      end

      # @return [ActiveFedora::Base]
      # @todo Actually authorize the resource!
      def load_and_authorize_resource
        @work = ActiveFedora::Base.find(params[:id])
      end

      # @return [true, false]
      def wants_file_set?
        work.is_a? FileSet
      end
  end
end
