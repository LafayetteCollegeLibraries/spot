# seed the application w/ some essentials

DEFAULT_USERS = %w[
  malantoa@lafayette.edu
  trustee_user@lafayette.edu
  faculty_user@lafayette.edu
]

ADMIN_USERS = %w[
  malantoa@lafayette.edu
]

Rake::Task['spot:roles:default'].invoke
Rake::Task['hyrax:default_admin_set:create'].invoke

DEFAULT_USERS.each { |email| User.create(email: email, password: 'letmein') }

admin = Role.find_by(name: 'admin')

ADMIN_USERS.each { |email| admin.users << User.find_by(email: email) }

admin.save!
