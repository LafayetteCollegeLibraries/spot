# probably a one-time thing, but since it's something

namespace :spot do
  namespace :trustee do
    desc 'creates Trustee admin_set (if it does not exist)'
    task admin_set_create: :environment do
      TrusteeAdminSetService.create!
    end
  end
end
