# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'
require 'sprockets/es6'
require 'rack-cas/session_store/active_record'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Spot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # use sidekiq for async jobs
    config.active_job.queue_adapter = :sidekiq

    config.active_record.schema_format = :sql

    config.action_mailer.default_url_options = { host: ENV['URL_HOST'] }
    config.action_mailer.preview_path = Rails.root.join('lib', 'mailer_previews')

    config.rack_cas.server_url = ENV.fetch('CAS_BASE_URL')
    config.rack_cas.service = '/users/service'
    config.rack_cas.extra_attributes_filter = %w(uid email givenName surname lnumber eduPersonEntitlement)
    config.rack_cas.session_store = RackCAS::ActiveRecordStore
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
