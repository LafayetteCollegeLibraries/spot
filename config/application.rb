# frozen_string_literal: true
require_relative 'boot'

require 'rails/all'
require 'sprockets/es6'

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
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.add_autoload_paths_to_load_path = true

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
    config.rack_cas.service = ENV['URL_HOST'].present? ? "#{ENV['URL_HOST']}/users/service" : '/users/service'
    config.rack_cas.extra_attributes_filter = %w[uid email givenName surname lnumber eduPersonEntitlement]

    hostname = ENV['APPLICATION_FQDN'] || URI.parse(ENV['URL_HOST'] || '').hostname
    config.hosts << hostname if hostname.present?

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    ##
    # When using the Goddess adapter of Hyrax 5.x, we want to have a
    # canonical answer for what are the Work Types that we want to manage.
    #
    # We don't want to rely on `Hyrax.config.curation_concerns`, as these are
    # the ActiveFedora implementations.
    #
    # @return [Array<Class>]
    def self.work_types
      Hyrax.config.curation_concerns.map do |cc|
        if cc.to_s.end_with?("Resource")
          cc
        else
          # We may encounter a case where we don't have an old ActiveFedora
          # model that we're mapping to.  For example, let's say we add Game as
          # a curation concern.  And Game has only ever been written/modeled via
          # Valkyrie.  We don't want to also have a GameResource.
          "#{cc}Resource".safe_constantize || cc
        end
      end
    end

  end
end
