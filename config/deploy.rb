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
set :init_system, -> { :upstart }
set :upstart_service_name, 'sidekiq'
set :sidekiq_roles, [:jobs]

# remapping commands
SSHKit.config.command_map[:rails] = 'bundle exec rails'
SSHKit.config.command_map[:rake] = 'bundle exec rake'
SSHKit.config.command_map[:sidekiq] = 'bundle exec sidekiq'
SSHKit.config.command_map[:sidekiqctl] = 'bundle exec sidekiqctl'
SSHKit.config.command_map[:solr] = '/opt/solr/bin/solr'

# shared things
append :linked_dirs, 'log'
append :linked_dirs, 'tmp/cache', 'tmp/derivatives', 'tmp/export', 'tmp/ingest', 'tmp/pids', 'tmp/sockets', 'tmp/uploads'
append :linked_dirs, 'vendor/bundle', 'node_modules'
append :linked_dirs, 'public/assets', 'public/branding', 'public/system', 'public/uploads'
