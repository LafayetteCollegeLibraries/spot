# frozen_string_literal: true
namespace :spot do
  namespace :student_work_admin_set do
    task create: [:environment] do
      id = AdminSet::STUDENT_WORK_ID
      admin_set = nil

      begin
        admin_set = AdminSet.find(id)
      rescue ActiveFedora::ObjectNotFoundError
        # Create the AdminSet object
        admin_set = AdminSet.create(id: id, title: ['Student Works'])
      rescue Ldp::Gone
        puts "AdminSet(#{id}) has been deleted. Run `AdminSet.eradicate('#{id}')` to clear the tombstone"
        next
      end

      # Create the corresponding PermissionTemplate if it doesn't exist
      # - admin users can manage
      # - registered users can deposit
      unless Hyrax::PermissionTemplate.exists?(source_id: id)
        permission_template = Hyrax::PermissionTemplate.create(
          source_id: admin_set.id,
          access_grants_attributes: {
            '0' => {
              agent_type: Hyrax::PermissionTemplateAccess::GROUP,
              agent_id: Ability.admin_group_name,
              access: Hyrax::PermissionTemplateAccess::MANAGE
            },
            '1' => {
              agent_type: Hyrax::PermissionTemplateAccess::GROUP,
              agent_id: Ability.registered_group_name,
              access: Hyrax::PermissionTemplateAccess::DEPOSIT
            }
          }
        )
      end

      # make sure the Sipity::Workflow exists
      workflow = Sipity::Workflow.find_by(name: 'mediated_student_work_deposit', permission_template: permission_template)

      if workflow.nil?
        # Generate the mediated_student_work_deposit workflow and assign it to the permission template.
        # The Importer will return each workflow defined in the json file, and ours only defines one.
        workflow = Hyrax::Workflow::WorkflowImporter.generate_from_json_file(
                     path: Rails.root.join('config', 'workflows', 'mediated_student_work_deposit_workflow.json').to_s,
                     permission_template: permission_template
                   ).first
      end

      unless workflow.active
        # activate the workflow
        workflow.active = true
        workflow.save
      end

      puts %(Successfully created "#{admin_set.title.first}" admin set)
    end
  end
end
