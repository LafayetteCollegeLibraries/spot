# frozen_string_literal: true
namespace :spot do
  desc 'copies appropriate .env file'
  task upload_dotenv_file: ['deploy:set_rails_env'] do
    on roles(:app) do
      dotenv_name = ".env.#{fetch(:stage)}"
      dotenv_path = File.expand_path("../../../../../#{dotenv_name}", __FILE__)

      # we'll upload it as the sole .env file so that we don't have to worry about
      # stage vs environment (we have different stage files but we're always deploying
      # as production in rails)
      upload!(dotenv_path, "#{release_path}/.env") if File.exist?(dotenv_path)
    end
  end
end

after 'deploy:symlink:linked_files', 'spot:upload_dotenv_file'
