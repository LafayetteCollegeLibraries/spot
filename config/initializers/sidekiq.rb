# frozen_string_literal: true
#
# Configuration for Sidekiq services
Sidekiq.configure_server do |config|
  ActiveJob::Base.logger = Sidekiq::Logging.logger

  # load our cron jobs from the config yaml file.
  schedule = Rails.root.join('config', 'sidekiq_schedule.yml')
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule)) if File.exist?(schedule)

  # tell Sidekiq about our redis customizations
  if ENV['REDIS_URL'] || ENV['REDIS_PASSWORD']
    config.redis = {}.tap do |redis|
      redis[:url] = ENV['REDIS_URL'] if ENV['REDIS_URL']
      redis[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD']
    end
  end
end

Sidekiq.configure_client do |config|
  # tell Sidekiq about our redis customizations
  if ENV['REDIS_URL'] || ENV['REDIS_PASSWORD']
    config.redis = {}.tap do |redis|
      redis[:url] = ENV['REDIS_URL'] if ENV['REDIS_URL']
      redis[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD']
    end
  end
end
