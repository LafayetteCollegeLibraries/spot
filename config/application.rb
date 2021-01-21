# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'
require 'sprockets/es6'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Spot
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # use sidekiq for async jobs
    config.active_job.queue_adapter = :sidekiq

    # route UnknownFormat errors to :not_found
    config.action_dispatch.rescue_responses.merge!(
      'ActionController::UnknownFormat' => :not_found
    )
  end
end
