# frozen_string_literal: true
require 'active_fedora/rake_support'
require 'rubocop/rake_task'

# borrowing from the Hyrax rubocop task
desc 'run code-style checker (+ fail on errors)'
RuboCop::RakeTask.new(:rubocop_ci) do |task|
  task.fail_on_error = true
end

namespace :spot do
  desc 'run tests in ci setting'
  task ci: [:rubocop_ci, 'spot:spec_with_server']

  task :spec_with_server do
    with_server 'test' do
      Rake::Task['spec'].invoke
    end
  end
end
