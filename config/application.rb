# frozen_string_literal: true
require_relative 'boot'

require 'logger'
require 'rails/all'

require 'sprockets/es6'
require 'rack-cas/session_store/active_record'

# Some gems in the Samvera stack use the 'deprecation' gem instead of
# ActiveSupport::Deprecation calls, so we need to also set _that_ gem's
# default behavior before requiring the stack's dependencies.
#
# @note dry-types uses its own Deprecation class but doesn't provide an API for silencing
if ActiveModel::Type::Boolean.new.cast(ENV.fetch('SPOT_IGNORE_DEPRECATIONS', false))
  require 'deprecation'

  ActiveSupport::Deprecation.silenced = true
  Deprecation.default_deprecation_behavior = :silence
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Spot
  class Application < Rails::Application
    config.load_defaults 6.0
    config.autoloader = :classic

    # use sidekiq for async jobs
    config.active_job.queue_adapter = :sidekiq

    config.active_record.schema_format = :sql

    config.action_mailer.default_url_options = { host: ENV['URL_HOST'] }
    config.action_mailer.preview_path = Rails.root.join('lib', 'mailer_previews')

    # Enables `lograge` gem which makes Rails logs more manageable (read: easier to work with using AWS tooling).
    #
    # @note if RAILS_LOG_LEVEL is set to anything higher than :debug, lograte will not have log
    #       entries to process, effectively making it useless.
    # @see https://github.com/roidrage/lograge/
    config.lograge.enabled = ENV.fetch('SPOT_ENABLE_LOGRAGE') { false }

    config.rack_cas.server_url = ENV['CAS_BASE_URL']
    config.rack_cas.service = '/users/service'
    config.rack_cas.extra_attributes_filter = %w[uid email givenName surname lnumber eduPersonEntitlement]

    config.hosts << URI.parse(ENV['URL_HOST'])&.hostname if ENV['URL_HOST'].present?
    config.hosts << 'localhost' if Rails.env.test?

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
