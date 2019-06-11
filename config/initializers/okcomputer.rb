# frozen_string_literal: true
#
# Configuration for OkComputer, an engine to register system healthchecks

# by default, OkComputer mounts at `/okcomputer`. setting this to `false`
# lets us mount it manually (and at a different endpoint) in config/routes.rb
OkComputer.mount_at = false

solr_config = Rails.application.config_for(:solr)
redis_config = Rails.application.config_for(:redis)
fcrepo_config = Rails.application.config_for(:fedora)

# rubocop:disable Security/YAMLLoad
sidekiq_config = YAML.load(ERB.new(IO.read(Rails.root.join('config', 'sidekiq.yml'))).result)
# rubocop:enable Security/YAMLLoad

fcrepo_uri = URI.parse(fcrepo_config['url']).tap do |uri|
  uri.userinfo = "#{fcrepo_config['user']}:#{fcrepo_config['password']}"
end.to_s

# out of the box, "application running?" and "active record working?" checks
# are run. we need to register the others
OkComputer::Registry.register 'solr', OkComputer::SolrCheck.new(solr_config['url'])
OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(redis_config)
OkComputer::Registry.register 'fedora', OkComputer::HttpCheck.new(fcrepo_uri)

sidekiq_config[:queues].each do |queue|
  OkComputer::Registry.register "sidekiq :#{queue}", OkComputer::SidekiqLatencyCheck.new(queue.to_sym)
end

if ENV['FITS_SERVLET_HOST'].present?
  fits_url = "#{ENV['FITS_SERVLET_HOST']}/fits/version"
  OkComputer::Registry.register 'fits (servlet)', OkComputer::HttpCheck.new(fits_url)
end
