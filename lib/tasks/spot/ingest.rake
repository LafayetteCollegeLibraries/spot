namespace :spot do
  namespace :ingest do
    {
      'ldr' => 'Lafayette Digital Repository',
      'magazine' => 'Lafayette Magazine archive',
      'newspaper' => 'Lafayette newspaper archive',
      'shakespeare' => 'Shakespeare Bulletin archive'
    }.each do |source, name|
      desc "Ingest zipped + bagged items from the #{name}"
      task source, [:path] => :environment do |t, args|
        unless args[:path]
          puts 'No :path provided!'
          puts "Use `bundle exec rails #{t}[/path/to/bag_file.zip]`"
          puts " or `bundle exec rails #{t}[/path/to/directory_of_bags]`"
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
  end
end
