# frozen_string_literal: true
#
# Configuration for Sidekiq services

Sidekiq.configure_server do
  ActiveJob::Base.logger = Sidekiq::Logging.logger
end
