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

  task :update_config do
    core_name = ENV.fetch('core') { "spot-#{fetch(:stage)}" }

    on roles(:solr) do
      # TODO: make this configurable?
      config_root = '/var/opt/solr/data'
      core_path = File.join(config_root, core_name)

      abort "directory for core \"#{core_name}\" does not exist" unless test(:ls, core_path)

      source_path = File.join(release_path, 'solr', 'config')
      target_path = File.join(core_path, 'conf')

      # the `-u` flag on linux only copies items with a newer timestamp on them.
      # the `-v` flag verbosely lists the files being copied
      execute :cp, '-ruv', "#{source_path}/*", target_path.to_s
    end
  end

  desc 'updates the solr config files and restarts the server'
  task reload_config: [:stop, :update_config, :start]
end
