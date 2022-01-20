# frozen_string_literal: true
RSpec.describe Spot::Workflow::GrantSipityRoleToAdvisor do
  # let(:depositor) { create(:user) }
  let(:workflow_role) { Sipity::WorkflowRole.find_or_create_by!(role: Sipity::Role[:advising], workflow: permission_template.active_workflow) }
  let(:advisor) { create(:user, lnumber: 'L12341234') }
  let(:advisor_key) { advisor.lnumber }
  let(:admin_set) { AdminSet.find(AdminSet.find_or_create_default_admin_set_id) }
  let(:default_access_grants) do
    [{ agent_type: 'group', agent_id: ::Ability.admin_group_name, access: Hyrax::PermissionTemplateAccess::MANAGE }]
  end
  let(:work) do
    build(:student_work,
          id: 'abc123',
          admin_set: admin_set,
          advisor: [advisor_key])
  end
  let(:permission_template) { Hyrax::PermissionTemplate.find_by!(source_id: AdminSet.find_or_create_default_admin_set_id) }
  let(:sipity_agent) { advisor.to_sipity_agent }
  let(:sipity_entity) { Sipity::Entity.find_or_create_by!(proxy_for_global_id: work.to_global_id.to_s, workflow: permission_template.active_workflow) }

  # needed for "Hyrax workflow method" shared_example
  let(:workflow_method) { described_class }

  before do
    # ensure that a permission template exists and is active
    Hyrax::PermissionTemplate.create!(source_id: admin_set.id, access_grants_attributes: default_access_grants)
    Hyrax::Workflow::WorkflowImporter.load_workflows

    # activate the first workflow we get (doesn't matter which)
    permission_template.available_workflows.first.tap { |pt| pt.active = true }.save

    # need to stub so we can test that it's been called
    allow(Sipity::EntitySpecificResponsibility)
      .to receive(:find_or_create_by!)
      .with(workflow_role: workflow_role, entity: sipity_entity, agent: sipity_agent)
  end

  it_behaves_like 'a Hyrax workflow method'

  context 'when "advisor" is an L-number' do
    let(:advisor_key) { advisor.lnumber }

    it "grants a Sipity::Role to the user" do
      described_class.call(target: work)

      expect(Sipity::EntitySpecificResponsibility)
        .to have_received(:find_or_create_by!)
        .with(workflow_role: workflow_role, entity: sipity_entity, agent: sipity_agent)
    end
  end

  context 'when "advisor" is an email' do
    let(:advisor_key) { advisor.email }

    it "grants a Sipity::Role to the user" do
      described_class.call(target: work)

      expect(Sipity::EntitySpecificResponsibility)
        .to have_received(:find_or_create_by!)
        .with(workflow_role: workflow_role, entity: sipity_entity, agent: sipity_agent)
    end
  end
end
