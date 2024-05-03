# frozen_string_literal: true
module Spot
  # @todo do we need this service anymore?
  class StudentWorkAdminSetCreateService
    class_attribute :admin_set_id,  default: 'admin_set/student_work'
    class_attribute :default_title, default: ['Student Work'].freeze
    class_attribute :workflow_name, default: 'mediated_student_work_deposit'

    def self.find_or_create_student_work_admin_set_id
      return admin_set_id if AdminSet.exists?(admin_set_id)

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
      AdminSet.create(id: admin_set_id, title: default_title)
    end

    def create_permission_template!(admin_set:)
      permissions = find_or_create_permission_template(source_id: admin_set.id)
      permissions.reset_access_controls_for(collection: admin_set)
      permissions
    end

    def find_or_create_permission_template(source_id:)
      Hyrax::PermissionTemplate.find_or_create_by(source_id: source_id) do |template|
        template.access_grants_attributes = access_grants_attributes
      end
    end

    def find_or_create_workflow(permission_template:)
      workflow = Sipity::Workflow.find_by(name: workflow_name, permission_template: permission_template)
      return workflow unless workflow.nil?

      Hyrax::Workflow::WorkflowImporter.generate_from_json_file(path: workflow_json_path, permission_template: permission_template).first
    end

    def workflow_json_name
      "#{workflow_name}_workflow.json"
    end

    def workflow_json_path
      Rails.root.join('config', 'workflows', workflow_json_name)
    end
  end
end
