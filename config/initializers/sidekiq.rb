# frozen_string_literal: true
#
# Configuration for Sidekiq services
Sidekiq.configure_server do
  ActiveJob::Base.logger = Sidekiq::Logging.logger

  # load our cron jobs from the config yaml file.
  schedule = Rails.root.join('config', 'sidekiq_schedule.yml')
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule)) if File.exist?(schedule)
end
