# frozen_string_literal: true
module Spot
  class StudentWorkAdminSetCreateService
    ADMIN_SET_ID = 'admin_set/student_work'
    DEFAULT_TITLE = ['Student Work'].freeze
    WORKFLOW_NAME = 'mediated_student_work_deposit'

    def self.find_or_create_student_work_admin_set_id
      return ADMIN_SET_ID if AdminSet.exists?(ADMIN_SET_ID)

      new.create_student_work_admin_set.id
    end

    def create_student_work_admin_set
      raise "Couldn't create StudentWork admin_set because #{workflow_json_name} does not exist" unless File.exist?(workflow_json_path)

      admin_set = create_admin_set
      permission_template = create_permission_template!(admin_set: admin_set)
      workflow = find_or_create_workflow(permission_template: permission_template)
      activate_workflow!(workflow: workflow, permission_template: permission_template)
      admin_set
    end

    private

    # Admins can manage, Registered users can deposit
    def access_grants_attributes
      [
        { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: Ability.admin_group_name, access: Hyrax::PermissionTemplateAccess::MANAGE },
        { agent_type: Hyrax::PermissionTemplateAccess::GROUP, agent_id: Ability.registered_group_name, access: Hyrax::PermissionTemplateAccess::DEPOSIT }
      ]
    end

    def activate_workflow!(workflow:, permission_template:)
      Sipity::Workflow.activate!(permission_template: permission_template, workflow_id: workflow.id)
    end

    def create_admin_set
      AdminSet.create(id: ADMIN_SET_ID, title: DEFAULT_TITLE)
    end

    def create_permission_template!(admin_set:)
      permissions = Hyrax::PermissionTemplate.create!(source_id: admin_set.id, access_grants_attributes: access_grants_attributes)
      admin_set.reset_access_controls!
      permissions
    end

    def find_or_create_workflow(permission_template:)
      workflow = Sipity::Workflow.find_by(name: WORKFLOW_NAME, permission_template: permission_template)
      return workflow unless workflow.nil?

      Hyrax::Workflow::WorkflowImporter.generate_from_json_file(path: workflow_json_path, permission_template: permission_template).first
    end

    def workflow_json_name
      "#{WORKFLOW_NAME}_workflow.json"
    end

    def workflow_json_path
      Rails.root.join('config', 'workflows', workflow_json_name)
    end
  end
end
