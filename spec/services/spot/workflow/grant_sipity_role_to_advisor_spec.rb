# frozen_string_literal: true
RSpec.describe Spot::Workflow::GrantSipityRoleToAdvisor do
  let(:workflow_method) { described_class }
  let(:workflow_role) { Sipity::Role[:advising] }
  let(:advisor) { create(:user, lnumber: 'L12341234') }
  let(:depositor) { create(:user) }
  let(:work) { build(:student_work, id: 'abc123', advisor: [advisor_key], user: depositor) }
  let(:sipity_agent) { advisor.to_sipity_agent }
  let(:advisor_key) { advisor.lnumber }
  let(:default_permission_template) { Hyrax::PermissionTemplate.find_by(source_id: AdminSet.find_or_create_default_admin_set_id) }
  let(:sipity_entity) { instance_double('Sipity::Entity') }

  before do
    allow(Sipity::Entity)
      .to receive(:find_or_create_by!)
      .with(proxy_for_global_id: work.to_global_id.to_s)
      .and_return(sipity_entity)

    allow(Sipity::EntitySpecificResponsibility).to receive(:find_or_create_by!)
  end

  it_behaves_like 'a Hyrax workflow method'

  context 'when "advisor" is an L-number' do
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
