# frozen_string_literal: true
namespace :spot do
  namespace :student_work_admin_set do
    task create: [:environment] do
      admin_set = nil

      begin
        admin_set = AdminSet.find(Spot::StudentWorkAdminSetCreateService.find_or_create_student_work_admin_set_id)
      rescue Ldp::Gone
        puts "AdminSet(ID=#{Spot::StudentWorkAdminSetCreateService::ADMIN_SET_ID}) has been deleted."
        next
      end

      puts %(Successfully created "#{admin_set.title.first}" admin set)
    end
  end
end
