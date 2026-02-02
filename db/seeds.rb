# frozen_string_literal: true
#
# Copying seeds from Hyrax, adding additional LDR steps after
# @see https://github.com/samvera/hyrax/blob/hyrax-v5.2.0/db/seeds.rb
ActiveFedora.fedora.connection.send(:init_base_path)

puts "\n== Creating default collection types"
Hyrax::CollectionType.find_or_create_default_collection_type
Hyrax::CollectionType.find_or_create_admin_set_type

puts "\n== Loading workflows"
Hyrax::Workflow::WorkflowImporter.load_workflows
errors = Hyrax::Workflow::WorkflowImporter.load_errors
abort("Failed to process all workflows:\n  #{errors.join('\n  ')}") unless errors.empty?

puts "\n== Creating default admin set"
admin_set_id = Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s

puts "\n== Ensuring the found or created admin set is indexed"
AdminSet.find(admin_set_id).update_index

# Legacy seeding done by Rake tasks
# @see lib/tasks/spot

# create roles, deposit user, + admin_sets
Rake::Task['spot:roles:default'].invoke
Rake::Task['spot:create_deposit_user'].invoke
Rake::Task['spot:student_work_admin_set:create'].invoke

# Pass dev admin users via environment variable,separate with commas
# @example
#   DEV_ADMIN_USERS="malantoa@lafayette.edu,facultyuser@lafayette.edu"
#
if ENV['DEV_ADMIN_USERS'].present?
  admin = Role.find_by(name: 'admin')

  ENV['DEV_ADMIN_USERS'].split(/,\s*/).each do |email|
    username = email.gsub(/@.+/, '')
    admin.users << User.find_or_create_by(username: username, email: email)
  end

  admin.save
end
