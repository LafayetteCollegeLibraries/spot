class TrusteeAdminSetService
  TRUSTEE_ID = 'admin_set/trustee'
  TRUSTEE_TITLE = ['Board of Trustee Documents']
  TRUSTEE_GROUPS = %w[admin trustee]

  def self.create!
    new.create!
  end

  def create!
    return if AdminSet.exists? TRUSTEE_ID

    admin_set.tap do |result|
      if result
        permission_template = create_permission_template
        create_workflows_for(permission_template)
      end
    end
  end

  private

  def admin_set
    @admin_set ||= AdminSet.create!(admin_set_attributes)
  end

  def access_grants_attributes
    group_names.map do |group|
      { agent_type: 'group', agent_id: group, access: Hyrax::PermissionTemplateAccess::MANAGE }
    end
  end

  def admin_set_attributes
    {
      id: TRUSTEE_ID,
      title: TRUSTEE_TITLE,
      edit_groups: group_names,
      read_groups: group_names,
      discover_groups: group_names
    }
  end

  def create_permission_template
    Hyrax::PermissionTemplate.create!(admin_set_id: admin_set.id, access_grants_attributes: access_grants_attributes)
  end

  def create_workflows_for(permission_template)
    Hyrax::Workflow::WorkflowImporter.load_workflow_for(permission_template: permission_template)

    Sipity::Role[Hyrax::RoleRegistry::MANAGING]

    permission_template.available_workflows.each do |workflow|
      Sipity::Role.all.each do |role|
        workflow.update_responsibilities(role: role, agents: workflow_agents)
      end
    end

    Sipity::Workflow.activate!(
      permission_template: permission_template,
      workflow_name: Hyrax.config.default_active_workflow_name
    )
  end

  def groups
    @groups ||= TRUSTEE_GROUPS.map { |id| Role.find_or_create_by(name: id) }
  end

  def group_names
    groups.map(&:name)
  end

  def workflow_agents
    TRUSTEE_GROUPS.map { |id| Hyrax::Group.new(id) }
  end
end
