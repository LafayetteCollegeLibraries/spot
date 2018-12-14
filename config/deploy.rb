# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.11.0'

set :application, 'spot'
set :repo_url, 'https://github.com/LafayetteCollegeLibraries/spot.git'
set :rails_env, 'production'

set :deploy_to, '/var/www/spot'

set :log_level, :debug
set :bundle_flags, '--deployment'
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 3
set :assets_prefix, '#{shared_path}/public/assets'

SSHKit.config.command_map[:rake] = 'bundle exec rake'

set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

append :linked_dirs, 'log'
append :linked_dirs, 'tmp/pids', 'tmp/cache', 'tmp/sockets'
append :linked_dirs, 'vendor/bundle'
append :linked_dirs, 'public/system', 'public/uploads', 'public/assets'

# append :linked_files, 'config/database.yml'
# append :linked_files, 'config/secrets.yml'

# TODO: set up sidekiq as a systemctl task or rewrite these
#       sidekiq restart tasks
#
# We have to re-define capistrano-sidekiq's tasks to work with
# systemctl in production. Note that you must clear the previously-defined
# tasks before re-defining them.
#
# Rake::Task['sidekiq:stop'].clear_actions
# Rake::Task['sidekiq:start'].clear_actions
# Rake::Task['sidekiq:restart'].clear_actions
# namespace :sidekiq do
#   task :stop do
#     on roles(:app) do
#       execute :sudo, :systemctl, :stop, :sidekiq
#     end
#   end
#   task :start do
#     on roles(:app) do
#       execute :sudo, :systemctl, :start, :sidekiq
#     end
#   end
#   task :restart do
#     on roles(:app) do
#       execute :sudo, :systemctl, :restart, :sidekiq
#     end
#   end
# end
