# frozen_string_literal: true

# we're releasing off of `release`, so anything going on to
# the stage application will most likely be from our `develop` branch
set :branch, ENV.fetch('BRANCH') { 'develop' }

set :sidekiq_concurrency, 10

server 'nostromo0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[app db web]

server 'parker0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[app jobs]

server 'muthur0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[solr fedora]
