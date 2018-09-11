set :stage, :sandbox
set :rails_env, 'production'
server 'spot.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
