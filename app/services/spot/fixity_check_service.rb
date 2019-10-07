# frozen_string_literal: true
module Spot
  class FixityCheckService
    def self.perform(force: false)
      new.perform(force: force)
    end

    def initialize
      @success_count = 0
      @failure_count = 0
      @failed_item_ids = []
      @batch = ::FixityCheckBatch.create(summary: nil, completed: false)
    end

    def perform(force: false)
      opts = { async_jobs: false }
      opts[:max_days_between_fixity_checks] = -1 if force

      ::FileSet.find_each do |file_set|
        add_check_to_batch(fixity_check_result(file_set, opts))
      end

      summarize_and_save_batch!
      @batch
    end

    private

      def add_check_to_batch(log_object)
        log_object.each_pair do |key, value|
          value.each do |log|
            @success_count += 1 unless log.failed?
            @failure_count += 1 if log.failed?
            @failed_item_ids << key if log.failed?

            @batch.checksum_audit_logs << log
          end
        end
      end

      def fixity_check_result(file_set, opts)
        Hyrax::FileSetFixityCheckService.new(file_set, opts).fixity_check
      end

      def summarize_and_save_batch!
        summary = {
          success: @success_count,
          failed: @failure_count,
          failed_item_ids: @failed_item_ids.compact.uniq,
          total_time: (Time.zone.now - @batch.created_at)
        }

        @batch.update!(summary: summary, completed: true)
      end
  end
end
