# frozen_string_literal: true
#
# Configuration for OkComputer, an engine to register system healthchecks

# by default, OkComputer mounts at `/okcomputer`. setting this to `false`
# lets us mount it manually (and at a different endpoint) in config/routes.rb
OkComputer.mount_at = false

OkComputer.check_in_parallel = true

solr_config = Rails.application.config_for(:solr)
fcrepo_config = Rails.application.config_for(:fedora)
redis_config = Rails.application.config_for(:redis)
sidekiq_config = YAML.load(ERB.new(IO.read(Rails.root.join('config', 'sidekiq.yml'))).result)
fcrepo_uri = nil

if fcrepo_config['url'].present?
  fcrepo_uri = URI.parse(fcrepo_config['url']).tap do |uri|
    uri.userinfo = "#{fcrepo_config['user']}:#{fcrepo_config['password']}"
  end.to_s
end

# out of the box, "application running?" and "active record working?"
# checks are run. we need to register the others
OkComputer::Registry.register('solr', OkComputer::SolrCheck.new(solr_config['url'])) if solr_config['url']
OkComputer::Registry.register('redis', OkComputer::RedisCheck.new(redis_config)) if redis_config.present?
OkComputer::Registry.register('fedora', OkComputer::HttpCheck.new(fcrepo_uri)) if fcrepo_uri

sidekiq_config.fetch(:queues, []).each do |queue|
  OkComputer::Registry.register "sidekiq :#{queue}", OkComputer::SidekiqLatencyCheck.new(queue.to_sym)
end
