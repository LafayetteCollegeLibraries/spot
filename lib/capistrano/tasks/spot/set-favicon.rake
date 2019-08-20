# frozen_string_literal: true

namespace :spot do
  desc 'Sets the favicon based on the environment'
  task :set_favicon do
    on roles(:web) do
      within release_path do
        public_path = File.join(release_path, 'public')

        target_file = File.join(public_path, "favicon-#{fetch(:stage)}.ico")
        favicon_path = File.join(public_path, 'favicon.ico')

        execute(:mv, target_file, favicon_path)
        execute(:rm, File.join(public_path, 'favicon-*.ico'))
      end
    end
  end
end

after 'deploy:symlink:linked_dirs', 'spot:set_favicon'
