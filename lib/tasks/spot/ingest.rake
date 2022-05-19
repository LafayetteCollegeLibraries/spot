# frozen_string_literal: true
#
# ingest tasks to replace the previous infrastructure
namespace :spot do
  namespace :ingest do
    def scoped_ingest_for(work_type:)
      perform_ingest do |args|
        args[:work_type] = work_type
      end
    end

    def perform_ingest
      args = args_from_env
      yield args if block_given?

      args.delete_if { |_k, v| v.blank? }
      validate_arguments!(args)

      args[:file] = File.open(args.delete(:metadata_path), 'r')

      Spot::CSVIngestService.perform(**args)
    end

    def args_from_env
      {
        collection_ids: ENV.fetch('collection_ids', '').split(/[,|]/),
        source_path: ENV.fetch('source_path', ''),
        work_type: ENV.fetch('work_type', nil),
        metadata_path: ENV.fetch('metadata_path', ''),
        admin_set_id: ENV.fetch('admin_set_id', nil)
      }
    end

    def validate_arguments!(args)
      abort "No metadata file provided via 'metadata_path' environment variable" unless args.include?(:metadata_path)
      abort "File provided to 'metadata_path' does not exist" unless File.exist?(args[:metadata_path])
      abort "'source_path' does not exist" unless Dir.exist?(args[:source_path])
    end

    task csv: [:environment] do
      perform_ingest
    end

    %i[publication image student_work].each do |work_type|
      task work_type => [:environment] do
        scoped_ingest_for(work_type: work_type)
      end
    end
  end
end
