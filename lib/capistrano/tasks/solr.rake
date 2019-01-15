# frozen_string_literal: true

namespace :solr do
  desc 'starts the solr server'
  task :start do
    on roles(:solr) do
      execute :solr, :start
    end
  end

  desc 'stops the solr server'
  task :stop do
    on roles(:solr) do
      execute :solr, :stop
    end
  end
end
