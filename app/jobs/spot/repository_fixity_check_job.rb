# frozen_string_literal: true
#
# NOTE: This job performs the fixity-checking synchronously (see below).
# Be sure to run this when there is no processing needed!
#
# The Hyrax::RepositoryFixityCheckService enqueues all of the fixity-check
# jobs asynchronously. We found that this results in quite a few false
# failures. Running the service as it's defined below removes those false failures
# (note: I'm calling them "false failures" because viewing the files in Fedora
# shows that the fixity checks succeeded).
#
# Running the checks this way allows us to send a follow-up email/post
# when the jobs are done running.
module Spot
  class RepositoryFixityCheckJob < ApplicationJob
    around_perform :wrap_check

    # @param [true, false] :force Ignore the 'max days between check' parameter
    def perform(force: false)
      opts = { async_jobs: false }
      opts[:max_days_between_fixity_checks] = -1 if force

      @count = 0

      ::FileSet.find_each do |file_set|
        @count += 1
        Hyrax::FileSetFixityCheckService.new(file_set, opts).fixity_check
      end
    end

    private

      # Wraps our check to pass a time to the send_fixity_status_job.
      #
      # @yields
      # @return [void]
      def wrap_check
        start = Time.now

        yield

        SendFixityStatusJob.perform_now(item_count: @count, job_time: (Time.now - start))
      end
  end
end
