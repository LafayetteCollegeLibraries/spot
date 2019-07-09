# frozen_string_literal: true
require 'redis'
config = YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
config[:password] = ENV['REDIS_PASSWORD'] unless ENV['REDIS_PASSWORD'].nil?

Redis.current = Redis.new(config.merge(thread_safe: true))
