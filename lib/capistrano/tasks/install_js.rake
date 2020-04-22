# frozen_string_literal: true
namespace :spot do
  desc 'Installs package.json dependencies'
  task :install_js_dependencies do
    on roles(:web) do
      execute :yarn, :install
    end
  end
end

before 'deploy:assets:precompile', 'spot:install_js_dependencies'
