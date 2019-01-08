# frozen_string_literal: true
#
# Configuration for OkComputer, an engine to register system healthchecks

# by default, OkComputer mounts at `/okcomputer`. setting this to `false`
# lets us mount it manually (and at a different endpoint) in config/routes.rb
OkComputer.mount_at = false

env = Rails.env

solr_config =
  YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'solr.yml'))).result)[env]
redis_config =
  YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'redis.yml'))).result)[env]
fcrepo_config =
  YAML.safe_load(ERB.new(IO.read(Rails.root.join('config', 'fedora.yml'))).result)[env]

fcrepo_uri = URI.parse(fcrepo_config['url']).tap do |uri|
  uri.userinfo = "#{fcrepo_config['user']}:#{fcrepo_config['password']}"
end.to_s

# out of the box, "application running?" and "active record working?" checks
# are run. we need to register the others
OkComputer::Registry.register 'solr', OkComputer::SolrCheck.new(solr_config['url'])
OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(redis_config)
OkComputer::Registry.register 'fedora', OkComputer::HttpCheck.new(fcrepo_uri)
OkComputer::Registry.register 'queue_default', OkComputer::SidekiqLatencyCheck.new(:default)
