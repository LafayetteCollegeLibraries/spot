# frozen_string_literal: true
#
# Configuration for OkComputer, an engine to register system healthchecks

module Spot
  class CantaloupeCheck < ::OkComputer::HttpCheck
    require 'json'
    require 'openssl'

    def check
      response = JSON.parse(perform_request)
      message = case response['color']
                when 'GREEN' then 'Cantaloupe check successful!'
                when 'YELLOW' then "WARNING: #{response['message']}"
                when 'RED' then "ERROR: #{response['message']}"
                end
      mark_message(message)
      mark_failure unless response['color'] == 'GREEN'
    rescue => e
      mark_message("Error: '#{e}'")
      mark_failure
    end
  end

  def perform_request
    Timeout.timeout(request_timeout) do
      options = { read_timeout: request_timeout }

      options[:http_basic_authentication] = basic_auth_options if basic_auth_options.any?
      options[:ssl_verify_mode] = OpenSSL::SSL::VERIFY_NONE

      url.read(options)
    end
  rescue => e
    raise ConnectionFailed, e
  end
end

# by default, OkComputer mounts at `/okcomputer`. setting this to `false`
# lets us mount it manually (and at a different endpoint) in config/routes.rb
OkComputer.mount_at = false

solr_config = Rails.application.config_for(:solr)
fcrepo_config = Rails.application.config_for(:fedora)
redis_config = Rails.application.config_for(:redis)
sidekiq_config = YAML.load(ERB.new(IO.read(Rails.root.join('config', 'sidekiq.yml'))).result)
fcrepo_uri = nil

if fcrepo_config['url'].present?
  parsed = URI.parse(fcrepo_config['url'])
  parsed.userinfo = "#{fcrepo_config['user']}:#{fcrepo_config['password']}"

  fcrepo_uri = parsed
end

# out of the box, "application running?" and "active record working?"
# checks are run. we need to register the others
OkComputer::Registry.register('solr', OkComputer::SolrCheck.new(solr_config['url'])) if solr_config['url']
OkComputer::Registry.register('redis', OkComputer::RedisCheck.new(redis_config)) if redis_config.present?
OkComputer::Registry.register('fedora', OkComputer::HttpCheck.new(fcrepo_uri)) if fcrepo_uri
OkComputer::Registry.register('cantaloupe', Spot::CantaloupeCheck.new("#{ENV['URL_HOST']}/iiif/health")) if ENV['URL_HOST'].present?

sidekiq_config.fetch(:queues, []).each do |queue|
  OkComputer::Registry.register "sidekiq :#{queue}", OkComputer::SidekiqLatencyCheck.new(queue.to_sym)
end

if ENV['FITS_SERVLET_URL'].present?
  fits_url = "#{ENV['FITS_SERVLET_URL']}/version"
  OkComputer::Registry.register 'fits (servlet)', OkComputer::HttpCheck.new(fits_url)
end
