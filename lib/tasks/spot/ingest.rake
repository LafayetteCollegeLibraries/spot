# frozen_string_literal: true

namespace :spot do
  def check_env
    if !ENV['source']
      'No `source` provided!'
    elsif !ENV['path']
      'No `path` provided!'
    elsif !File.exist?(ENV['path'])
      'File or path does not exist'
    elsif !ENV['work_class']
      'No `work_class` provided!'
    end
  end

  def check_for_errors!
    return true unless (msg = check_env)

    common_envs = 'source=<source> work_class=<work class>'

    puts msg
    puts "Use `bundle exec rails #{t} #{common_envs} path=</path/to/bag_file.zip>"
    puts " or `bundle exec rails #{t} #{common_envs} path=</path/to/directory_of_bags"
    exit
  end

  def job_args_from_env
    {
      collection_ids: ENV.fetch('collection_ids', '').split(','),
      multi_value_character: ENV.fetch('multi_value_character', '|'),
      source: ENV['source'],
      work_class: ENV['work_class'],
      working_path: ENV.fetch('working_path', Rails.root.join('tmp', 'ingest').to_s)
    }
  end

  def enqueue_jobs(base_args = job_args_from_env)
    paths = File.directory?(ENV['path']) ? Dir[File.join(ENV['path'], '*.zip')] : [ENV['path']]
    paths.each { |e| Spot::IngestZippedBagJob.perform_later(base_args.merge(zip_path: e)) }
    true
  end

  desc 'Ingest items from zipped BagIt files'
  task ingest: :environment do
    check_for_errors! && enqueue_jobs
  end

  namespace :ingest do
    desc 'Ingest Publication items from zipped BagIt files'
    task publication: :environment do
      ENV['work_class'] = 'Publication'
      check_for_errors! && enqueue_jobs(job_args_from_env.merge(work_class: 'Publication'))
    end
  end
end
