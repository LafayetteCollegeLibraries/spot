namespace :spot do
  namespace :rdf do
    desc 'clear RdfLabel cache older than N days (default is 60)'
    task :clear_labels, [:time] => [:environment] do |_t, args|
      args.with_defaults(time: 60)

      time = args[:time]
      count = RdfLabel.where('created_at < ?', time.to_i.days.ago)
                      .destroy_all
                      .size

      puts "Purged #{count} #{'label'.pluralize(count)} older than #{time} #{'day'.pluralize(time)} ago"
    end
  end
end
