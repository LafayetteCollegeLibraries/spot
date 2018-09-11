# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

set :application, "spot"
set :repo_url, "https://github.com/LafayetteCollegeLibraries/spot.git"

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads'

set :deploy_to, '/opt/spot'

set :log_level, :debug
set :bundle_flags, '--deployment'
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 5
set :assets_prefix, "#{shared_path}/public/assets"

SSHKit.config.command_map[:rake] = 'bundle exec rake'

set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

append :linked_dirs, "log"
append :linked_dirs, "public/assets"

append :linked_files, ".env.production"

append :linked_files, "config/database.yml"
append :linked_files, "config/secrets.yml"

# We have to re-define capistrano-sidekiq's tasks to work with
# systemctl in production. Note that you must clear the previously-defined
# tasks before re-defining them.
Rake::Task["sidekiq:stop"].clear_actions
Rake::Task["sidekiq:start"].clear_actions
Rake::Task["sidekiq:restart"].clear_actions
namespace :sidekiq do
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :sidekiq
    end
  end
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, :sidekiq
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :sidekiq
    end
  end
end
