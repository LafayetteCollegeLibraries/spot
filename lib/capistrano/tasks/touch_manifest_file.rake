# frozen_string_literal: true
#
# creates a dummy 'manifest.tmp' file if one doesn't exist. this will
# prevent +deploy:assets:backup+ from failing on a fresh deployment
task :touch_manifest_file do
  on roles(:app) do
    execute :touch, shared_path.join('public', 'assets', 'manifest.tmp') unless
      fetch(:assets_manifests).any? { |candidate| test(:ls, candidate) }
  end
end

before 'deploy:assets:backup_manifest', :touch_manifest_file
