namespace :spot do
  namespace :ingest do
    task :zipped_bag, [:path] do |t, args|
      unless args[:path]
        puts 'No :path provided!'
        puts "Use `bundle exec rails #{t}[/path/to/bag_file.zip]`"
        puts " or `bundle exec rails #{t}[/path/to/directory_of_bags]`"
        exit
      end

      path = args[:path]

      if File.directory? path
        Dir[File.join(path, '*.zip')].each do |entry|
          ::IngestZippedBagJob.perform_later entry
        end
      else
        ::IngestZippedBagJob.perform_later path
      end
    end
  end
end
