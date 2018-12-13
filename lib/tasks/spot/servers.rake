# frozen_string_literal: true
# borrowed from hydra_head task.
# sets up a `dev_server` and `test_server` task to reduce the # of terminal
# tabs you have to open + start the appropriate wrappers for.
require 'active_fedora/rake_support'

namespace :spot do
  %w[development test].each do |env|
    shortname = env == 'development' ? 'dev' : env

    desc "runs Fedora + Solr using #{env} configs"
    task :"#{shortname}_server" => :environment do
      with_server(env) do
        solr_port = ENV.fetch("SOLR_#{env.upcase}_PORT")
        fcrepo_port = ENV.fetch("FCREPO_#{env.upcase}_PORT")

        begin
          puts '~~~~~~~~~~~~~'
          puts "Running with [#{env}] configurations:"
          puts "🔍 solr @ http://127.0.0.1:#{solr_port}"
          puts "🗄 fcrepo @ http://127.0.0.1:#{fcrepo_port}"
          puts '~~~~~~~~~~~~~'
          sleep
        rescue Interrupt
          puts 'stopping server(s)'
        end
      end
    end
  end
end
