# frozen_string_literal: true
namespace :spot do
  namespace :student_work_admin_set do
    task create: [:environment] do
      admin_set = nil
      begin
        admin_set = Spot::StudentWorkAdminSetCreateService.find_or_create_student_work_admin_set
      rescue Ldp::Gone
        id = Spot::StudentWorkAdminSetCreateService::ADMIN_SET_ID
        puts "AdminSet(#{id}) has been deleted. Run `AdminSet.eradicate('#{id}')` to clear the tombstone"
        next
      end

      puts %(Successfully created "#{admin_set.title.first}" admin set)
    end
  end
end
