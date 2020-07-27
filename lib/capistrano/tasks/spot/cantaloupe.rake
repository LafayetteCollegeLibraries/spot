# frozen_string_literal: true
namespace :image_server do
  task :start do
    on roles(:iiif) do
      execute :sudo, :service, :cantaloupe, :start
    end
  end

  task :stop do
    on roles(:iiif) do
      execute :sudo, :service, :cantaloupe, :stop
    end
  end

  task :restart do
    on roles(:iiif) do
      execute :sudo, :service, :cantaloupe, :restart
    end
  end
end
