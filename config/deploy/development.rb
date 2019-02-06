# frozen_string_literal: true
#
# Our development server. Everything lives here as an attempt to
# prove that all of the pieces work together more than trying to
# host a lot of objects.
server 'nostromo0-0.dev.lafayette.edu', user: 'deploy', roles: %w[app db solr jobs web]
