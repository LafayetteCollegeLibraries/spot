# frozen_string_literal: true
namespace :spot do
  task create_system_users: [:environment] do
    batch_user = Spot::SystemUserService.batch_user
    puts "Created deposit user #{batch_user.display_name} <#{batch_user.email}>"

    audit_user = Spot::SystemUserService.audit_user
    puts "Created audit user #{audit_user.display_name} <#{audit_user.email}>"
  end
end
