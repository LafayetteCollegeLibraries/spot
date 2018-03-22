# borrowed pretty extensively from psu's scholarsphere app
# (https://github.com/psu-stewardship/scholarsphere/blob/b78954d/tasks/dev.rake#L32)
require 'active_fedora/cleaner'

namespace :spot do
  namespace :dev do
    task __reset: [
      :environment,
      :__clean_repo,
      :'db:drop',
      :'db:setup',
      :'hyrax:default_admin_set:create',
      :'hyrax:workflow:load'
    ]

    task :__clean_repo do
      ActiveFedora::Cleaner.clean!
    end

    desc '[CAUTION] clear out fcrepo + solr + postgresql database'
    task reset: :environment do
      ENV['RAILS_ENV'] = 'development'

      puts '~~~~~~~~ WARNING: RESETTING EVERYTHING! ~~~~~~~~'
      puts 'Are you sure?? This is heavy-duty + irrevocable!'
      print '(Type "yes". Anything else will cancel) > '
      value = STDIN.gets.chomp

      next unless value == 'yes'

      Rake::Task['spot:dev:__reset'].invoke
    end

    def clear_redis
      Redis.current.keys.map { |key| Redis.current.del(key) }
    rescue => e
      Logger.new(STDOUT).warn "WARNING: Redis might be down: #{e}"
    end

    def reset_directories
      # clear derivatives
      FileUtils.rm_rf Hyrax.config.derivatives_path
      FileUtils.mkdir_p Hyrax.config.derivatives_path

      # clear uploads
      FileUtils.rm_rf Hyrax.config.upload_path.call
      FileUtils.mkdir_p Hyrax.config.upload_path.call
    end
  end
end
