# frozen_string_literal: true

namespace :spot do
  desc 'Ingest items from zipped BagIt files'
  task :ingest, [:source, :path] => :environment do |t, args|
    error_message = if !args[:source]
                      'No :source provided!'
                    elsif !args[:path]
                      'No :path provided!'
                    end
    if error_message
      puts error_message
      puts "Use `bundle exec rails #{t}[<source>,</path/to/bag_file.zip>]`"
      puts " or `bundle exec rails #{t}[<source>,</path/to/directory_of_bags>]`"
      exit
    end

    path = args[:path]

    raise ArgumentError, 'File or path does not exist' unless File.exist?(path)

    if File.directory? path
      Dir[File.join(path, '*.zip')].each do |entry|
        ::IngestZippedBagJob.perform_later(entry, source: source)
      end
    else
      ::IngestZippedBagJob.perform_later(path, source: source)
    end
  end
end
