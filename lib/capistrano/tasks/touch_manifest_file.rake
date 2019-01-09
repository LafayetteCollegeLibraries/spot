# frozen_string_literal: true
#
# creates a dummy 'manifest.tmp' file if one doesn't exist. this will
# prevent +deploy:assets:backup+ from failing on a fresh deployment
task :touch_manifest_file do
  on roles(:app) do
    execute :touch, release_path.join('public', fetch(:assets_prefix), 'manifest.tmp') unless
      fetch(:assets_manifests).any? { |candidate| test(:ls, candidate) }
  end
end

before 'deploy:assets:backup_manifest', :touch_manifest_file
