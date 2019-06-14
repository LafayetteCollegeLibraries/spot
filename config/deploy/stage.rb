# frozen_string_literal: true
#
# Stage mirrors Production pretty closely (if not exactly).
server 'nostromo0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[app db web]

server 'parker0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[app jobs]

server 'muthur0-0.stage.lafayette.edu',
       user: 'deploy',
       roles: %w[solr fedora]
