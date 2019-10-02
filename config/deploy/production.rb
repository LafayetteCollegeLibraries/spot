# frozen_string_literal: true
set :sidekiq_concurrency, 10

server 'nostromo0-0.lafayette.edu',
       user: 'deploy',
       roles: %w[app db web]

server 'parker0-0.lafayette.edu',
       user: 'deploy',
       roles: %w[app jobs]

server 'muthur0-0.lafayette.edu',
       user: 'deploy',
       roles: %w[solr fedora]
