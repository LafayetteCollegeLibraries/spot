# frozen_string_literal: true
desc 'Installs UV@2.0.2 into public/universalviewer'
task :install_uv do
  on roles(:web) do
    uv_path = shared_path.join('public', 'universalviewer')
    info('UV already installed') && next unless test("[ -z \"$(ls -A #{uv_path})\" ]")

    within '/tmp' do
      execute :rm, '-r', 'universalviewer' if test('[ -d /tmp/universalviewer ]')
      execute :git, :clone, 'https://github.com/UniversalViewer/universalviewer'

      within 'universalviewer' do
        execute :git, :archive, 'v2.0.2', "| #{SSHKit.config.command_map[:tar]} -x -f - -C", uv_path
      end

      execute :rm, '-r', 'universalviewer'
    end
  end
end

after 'deploy:symlink:linked_dirs', 'install_uv'
