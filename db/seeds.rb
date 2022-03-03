# seed the application w/ some essentials

# essential hyrax setup
Rake::Task['hyrax:default_admin_set:create'].invoke
Rake::Task['hyrax:default_collection_types:create'].invoke

# local set up: create roles, deposit user, + admin_sets
Rake::Task['spot:roles:default'].invoke
Rake::Task['spot:create_deposit_user'].invoke
Rake::Task['spot:student_work_admin_set:create'].invoke

if ENV['DEV_ADMIN_USERS'].present?
  admin = Role.find_by(name: 'admin')

  ENV['DEV_ADMIN_USERS'].split(/,\s*/).each do |email|
    username = email.gsub(/@.+/, '')
    admin.users << User.find_or_create_by(username: username, email: email)
  end

  admin.save
end
