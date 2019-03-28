# frozen_string_literal: true
namespace :spot do
  task create_deposit_user: [:environment] do
    user = User.find_or_initialize_by(email: 'dss@lafayette.edu')
    next if user.persisted? && user.admin?

    user.display_name = 'DeposiBot'
    user.roles << Role.find_by(name: 'admin')
    user.save!

    puts 'Created deposit user DeposiBot <dss@lafayette.edu>'
  end
end
