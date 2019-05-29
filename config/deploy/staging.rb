# frozen_string_literal: true
#
# Staging mirrors Production pretty closely (if not exactly).
server 'nostromo0-0.dev.lafayette.edu',
       user: 'deploy',
       roles: %w[app db web]

server 'parker0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[jobs]

server 'muthur0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[solr fedora]
