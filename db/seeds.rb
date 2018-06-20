# seed the application w/ some essentials

DEFAULT_USERS = %w[
  malantoa@lafayette.edu
  trustee_user@lafayette.edu
  faculty_user@lafayette.edu
]

ADMIN_USERS = %w[
  malantoa@lafayette.edu
]

TRUSTEE_USERS = %w[
  malantoa@lafayette.edu
  trustee_user@lafayette.edu
]

Rake::Task['spot:roles:default'].invoke
Rake::Task['hyrax:default_admin_set:create'].invoke
Rake::Task['hyrax:default_collection_types:create'].invoke

DEFAULT_USERS.each { |email| User.create(email: email, password: 'letmein') }
# create a depositor user
deposibot = User.create!(email: 'dss@lafayette.edu', display_name: 'DeposiBot', password: 'beep-boop')

admin = Role.find_by(name: 'admin')
trustee = Role.find_by(name: 'trustee')

ADMIN_USERS.each { |email| admin.users << User.find_by(email: email) }
admin.users << deposibot
admin.save!

TRUSTEE_USERS.each { |email| trustee.users << User.find_by(email: email) }
trustee.users << deposibot
trustee.save!
