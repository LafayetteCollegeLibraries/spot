# frozen_string_literal: true
RSpec.describe Spot::Workflow::GrantSipityRoleToAdvisor do
  let(:workflow_role) { Sipity::WorkflowRole.find_or_create_by!(role: Sipity::Role[:advising], workflow: permission_template.active_workflow) }
  let(:advisors) { [create(:user), create(:user)] }
  let(:admin_set) { AdminSet.find(AdminSet.find_or_create_default_admin_set_id) }
  let(:default_access_grants) do
    [{ agent_type: 'group', agent_id: ::Ability.admin_group_name, access: Hyrax::PermissionTemplateAccess::MANAGE }]
  end
  let(:work) do
    build(:student_work,
          id: 'abc123',
          admin_set: admin_set,
          advisor: advisors.map(&:email))
  end
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set.id) }
  let(:sipity_entity) { Sipity::Entity.find_or_create_by!(proxy_for_global_id: work.to_global_id.to_s, workflow: permission_template.active_workflow) }

  # needed for "Hyrax workflow method" shared_example
  let(:workflow_method) { described_class }

  before do
    # ensure that a permission template exists and is active
    Hyrax::PermissionTemplate.find_or_create_by(source_id: admin_set.id)
    Hyrax::Workflow::WorkflowImporter.load_workflows

    # activate the first workflow we get (doesn't matter which)
    permission_template.available_workflows.first.tap { |pt| pt.active = true }.save
    permission_template.reload

    # need to stub so we can test that it's been called
    allow(Sipity::EntitySpecificResponsibility)
      .to receive(:find_or_create_by!)
      .with(workflow_role: workflow_role, entity: sipity_entity, agent: kind_of(Sipity::Agent))
  end

  it_behaves_like 'a Hyrax workflow method'

  it "grants a Sipity::Role to the user" do
    described_class.call(target: work)

    expect(Sipity::EntitySpecificResponsibility)
      .to have_received(:find_or_create_by!)
      .with(workflow_role: workflow_role, entity: sipity_entity, agent: kind_of(Sipity::Agent))
      .exactly(advisors.count).times
  end
end
