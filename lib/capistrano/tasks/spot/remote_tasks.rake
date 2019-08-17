# frozen_string_literal: true
#
# capistrano wrappings around spot tasks that we might want to do remotely
# rubocop:disable Metrics/BlockLength
namespace :spot do
  namespace :roles do
    task :add_user_to_role do
      role = ENV.fetch('role')
      user = ENV.fetch('user')

      on roles(:web) do
        within current_path do
          with rails_env: fetch(:rails_env) do
            execute(:rails, 'spot:roles:add_user_to_role', "user=#{user}", "role=#{role}")
          end
        end
      end
    end
  end

  task :status do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute(:bundle, :exec, :rails, 'spot:status')
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
