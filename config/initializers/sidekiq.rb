# frozen_string_literal: true
#
# Configuration for Sidekiq services

Sidekiq::Logging.logger.level = Logger::WARN if Rails.env.production?
