# borrowed from hydra_head task
require 'active_fedora/rake_support'

namespace :spot do
  desc 'runs Fedora + Solr using test configs'
  task test_server: :environment do
      with_server('test') do
        begin
          puts "solr: http://127.0.0.1:#{ENV.fetch('SOLR_TEST_PORT') }"
          puts "fcrepo: http://127.0.0.1:#{ENV.fetch('FCREPO_TEST_PORT') }"
          sleep
        rescue Interrupt
          puts 'stopping server(s)'
        end
      end
  end
end
