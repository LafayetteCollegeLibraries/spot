# frozen_string_literal: true

namespace :spot do
  namespace :collections do
    desc 'Create Collections from a config file'
    task create: [:environment] do
      config_path = ENV.fetch('config') { Rails.root.join('config', 'collections.yml') }

      YAML.safe_load(File.open(config_path)).each do |config|
        puts "Creating collection: #{config['title']}"
        Spot::CollectionFromConfig.from_yaml(config).create_or_update!
      end
    end

    desc 'List Collection ids and titles (useful when ingesting items)'
    task list: [:environment] do
      list = Collection.all.map { |c| [c.id, c.title.first] }
      puts " ID       || TITLE"
      puts "==========||=========="
      list.each { |(id, title)| puts "#{id} || #{title}" }
    end
  end
end
