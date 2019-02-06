# frozen_string_literal: true

namespace :spot do
  namespace :dev do
    task reload_solr_config: :environment do
      require 'yaml'
      require 'fileutils'

      config = YAML.safe_load(File.read(Rails.root.join('.solr_wrapper')))
      instance_dir = config['instance_dir']
      core_name = config['collection']['name']

      abort 'No core name found' unless core_name

      target_dir = Rails.root.join(instance_dir, 'server', 'solr', core_name, 'conf')
      source_dir = Rails.root.join('solr', 'config')

      FileUtils.cp_r("#{source_dir}/.", target_dir)
    end
  end
end
