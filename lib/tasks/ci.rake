require 'active_fedora/rake_support'

namespace :spot do
  desc 'run tests in ci setting'
  task ci: [:spec_with_server]

  task :spec_with_server do
    with_server 'test' do
      Rake::Task['spec'].invoke
    end
  end
end
