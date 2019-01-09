# frozen_string_literal: true

namespace :deploy do
  desc 'runs db:seed'
  task :seed do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rails, 'db:seed'
        end
      end
    end
  end
end

after 'deploy:migrating', 'deploy:seed'
