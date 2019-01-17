# frozen_string_literal: true
#
# capistrano wrappings around spot tasks that we might want to do remotely
namespace :spot do
  desc 'ingest a directory of zipped bags'
  task :ingest do
    # using fetch will cause the task to abort if the fields are missing
    source = ENV.fetch('source')
    work_class = ENV.fetch('work_class')
    path = ENV.fetch('path')

    tmp_path = File.join('/tmp', "spot-bag-ingest-#{Time.now.to_i}")

    on roles(:app) do
      upload!(path, tmp_path, recursive: true)
      within current_path do
        execute(:rails, 'spot:ingest', "source=#{source}", "work_class=#{work_class}", "path=#{tmp_path}")
      end
    end
  end

  namespace :roles do
    task :add_user_to_role do
      role = ENV.fetch('role')
      user = ENV.fetch('user')

      on roles(:app) do
        within current_path do
          execute(:rails, 'spot:roles:add_user_to_role', "user=#{user}", "role=#{role}")
        end
      end
    end
  end
end
