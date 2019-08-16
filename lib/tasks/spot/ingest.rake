# frozen_string_literal: true

namespace :spot do
  desc 'Ingest items from zipped BagIt files'
  task ingest: :environment do |t|
    source = ENV['source']
    path = ENV['path']
    work_class = ENV['work_class']
    collection_ids = ENV['collection_ids'].to_s.split(',')
    multi_value_character = ENV.fetch('multi_value_character', '|')
    working_path = ENV.fetch('working_path', Rails.root.join('tmp', 'ingest').to_s)

    error_message = if    !source       then 'No `source` provided!'
                    elsif !path         then 'No `path` provided!'
                    elsif !work_class   then 'No `work_class` provided!'
                    end

    if error_message
      common_envs = 'source=<source> work_class=<work class>'

      puts error_message
      puts "Use `bundle exec rails #{t} #{common_envs} path=</path/to/bag_file.zip>"
      puts " or `bundle exec rails #{t} #{common_envs} path=</path/to/directory_of_bags"
      exit
    end

    raise ArgumentError, 'File or path does not exist' unless File.exist?(path)

    paths = File.directory?(path) ? Dir[File.join(path, '*.zip')] : [path]

    paths.each do |entry|
      Spot::IngestZippedBagJob.perform_later(zip_path: entry,
                                             source: source,
                                             collection_ids: collection_ids,
                                             multi_value_character: multi_value_character,
                                             work_class: work_class,
                                             working_path: working_path)
    end
  end
end
