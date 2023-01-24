# frozen_string_literal: true
require 'redis'

config = Rails.application.config_for(:redis).with_indifferent_access
config[:password] = ENV['REDIS_PASSWORD'] unless ENV['REDIS_PASSWORD'].blank?

if config[:url].present?
  config.delete(:host)
  config.delete(:port)
end

Redis.current = Redis.new(config.merge(thread_safe: true))
