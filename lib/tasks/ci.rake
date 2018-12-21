# frozen_string_literal: true

unless Rails.env.production?
  require 'active_fedora/rake_support'
  require 'rubocop/rake_task'

  desc 'run code-style checker (+ fail on errors)'
  RuboCop::RakeTask.new(:rubocop)

  namespace :spot do
    desc 'run tests in ci setting'
    task ci: ['spot:spec_with_server']

    task :spec_with_server do
      with_server 'test' do
        Rake::Task['spec'].invoke
      end
    end
  end
end
