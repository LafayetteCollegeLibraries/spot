# frozen_string_literal: true
#
# borrowed pretty extensively from psu's scholarsphere app
# (https://github.com/psu-stewardship/scholarsphere/blob/b78954d/tasks/dev.rake#L32)
require 'active_fedora/cleaner'

namespace :spot do
  namespace :dev do
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

    task __reset: %i[
      environment
      __clean_repo
      db:drop
      __clear_redis
      __reset_directories
      db:setup
      db:seed
      hyrax:workflow:load
    ]

    task :__clean_repo do
      ActiveFedora::Cleaner.clean!
    end

    task __clear_redis: :environment do
      begin
        Redis.current.keys.map { |key| Redis.current.del(key) }
      rescue => e
        Logger.new(STDOUT).warn "WARNING: Redis might be down: #{e}"
      end
    end

    task __reset_directories: :environment do
      # clear derivatives
      FileUtils.rm_rf Hyrax.config.derivatives_path
      FileUtils.mkdir_p Hyrax.config.derivatives_path

      # clear uploads
      FileUtils.rm_rf Hyrax.config.upload_path.call
      FileUtils.mkdir_p Hyrax.config.upload_path.call
    end
  end
end
