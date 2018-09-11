# TODO: determine the right .env file

namespace :spot do
  desc 'copies appropriate .env file'
  task upload_dotenv_file: ['deploy:set_rails_env'] do
    on roles(:app) do
      dotenv_path = '.env.production'
      upload! dotenv_path, "#{shared_path}/#{dotenv_path}"
    end
  end
end

# before 'deploy:check:linked_files', 'spot:upload_dotenv_file'
