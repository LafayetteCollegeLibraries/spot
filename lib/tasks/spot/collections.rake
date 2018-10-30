# frozen_string_literal: true

namespace :spot do
  namespace :collections do
    desc 'Create Collections from a config file'
    task create: [:environment] do
      config_path = ENV.fetch('config') { Rails.root.join('config', 'collections.yml') }

      YAML.safe_load(File.open(config_path)).each do |config|
        Rails.logger.info "Creating collection: #{config['title']}"
        Spot::CollectionFromConfig.from_yaml(config).create
      end
    end
  end
end
