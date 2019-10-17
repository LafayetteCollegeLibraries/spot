# seed the application w/ some essentials

# essential hyrax setup
Rake::Task['hyrax:default_admin_set:create'].invoke
Rake::Task['hyrax:default_collection_types:create'].invoke

# local set up: create roles + default collections + deposit user
Rake::Task['spot:roles:default'].invoke
Rake::Task['spot:create_deposit_user'].invoke
Rake::Task['spot:collections:create'].invoke unless Rails.env.production?
