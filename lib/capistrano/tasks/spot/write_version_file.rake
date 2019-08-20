# frozen_string_literal: true
namespace :spot do
  task :write_version_file do
    on roles(:web) do
      tag = ''

      within repo_path do
        tag = capture(:git, :describe, '--tags', '2>', '/dev/null').strip
      end

      next if tag == ''

      within release_path do
        execute(:echo, %("#{tag}"), '>', 'VERSION')
      end
    end
  end
end

after 'git:create_release', 'spot:write_version_file'
