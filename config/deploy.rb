# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

# application variables
set :application, 'spot'
set :branch, ENV['BRANCH'] || 'master'
set :deploy_to, '/var/www/spot'
set :keep_releases, 3
set :repo_url, 'https://github.com/LafayetteCollegeLibraries/spot.git'

# capistrano-bundler
set :bundle_env_variables, nokogiri_use_system_libraries: 1
set :bundle_flags, '--deployment'
set :bundle_roles, %i[app]

# capistrano-rails
set :log_level, :debug
set :rails_env, 'production'
set :assets_roles, :app

# capistrano-sidekiq
#
# note: it's probably best to specify concurrency per-environment.
# the default we're using here is the minimum working amount that
# worked on our single-server development instance.
set :sidekiq_config, release_path.join('config', 'sidekiq.yml')
set :sidekiq_env, fetch(:rails_env)
set :sidekiq_processes, 1
set :sidekiq_concurrency, 4
set :sidekiq_role, :jobs

# remapping commands
SSHKit.config.command_map[:rails] = 'bundle exec rails'
SSHKit.config.command_map[:rake] = 'bundle exec rake'
SSHKit.config.command_map[:sidekiq] = 'bundle exec sidekiq'
SSHKit.config.command_map[:sidekiqctl] = 'bundle exec sidekiqctl'
SSHKit.config.command_map[:solr] = '/opt/solr/bin/solr'

# shared things
append :linked_dirs, 'log'
append :linked_dirs, 'tmp/cache', 'tmp/derivatives', 'tmp/export', 'tmp/ingest', 'tmp/pids', 'tmp/sockets', 'tmp/uploads'
append :linked_dirs, 'vendor/bundle'
append :linked_dirs, 'public/assets', 'public/branding', 'public/system', 'public/uploads'

# hotfix (for the moment)
# we need to keep public/universalviewer intact between deploys
# until the improved universal viewer work in hyrax is release
# (see: https://github.com/samvera/hyrax/commit/0e02c4adf26e74f2d892f575c93789bc166e53ad)
#
# until then, this directory should contain a git clone of the
# universalviewer repository, checked out to 'v2.0.1':
#
#   git clone https://github.com/universalviewer/universalviewer $SPOT_ROOT/public/universalviewer
#   cd $SPOT_ROOT/public/universalviewer
#   git checkout v2.0.1
#
append :linked_dirs, 'public/universalviewer'
