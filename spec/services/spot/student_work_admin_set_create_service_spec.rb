# frozen_string_literal: true
RSpec.describe Spot::StudentWorkAdminSetCreateService do
  describe '.find_or_create_student_work_admin_set_id', clean: true do
    subject { described_class.find_or_create_student_work_admin_set_id }

    context 'when the admin_set exists' do
      before do
        allow(AdminSet).to receive(:exists?).with(described_class::ADMIN_SET_ID).and_return(true)
      end

      it { is_expected.to eq described_class::ADMIN_SET_ID }
    end

    context 'when the admin_set does not exist' do
      let(:admin_set) { AdminSet.find(described_class.find_or_create_student_work_admin_set_id) }

      # This is going to be expensive, so I'm just going to test everything in the one block
      it 'creates an AdminSet, Hyrax::PermissionTemplates, Sipity::Workflow and activates the workflow' do
        # described_class.find_or_create_student_work_admin_set_id

        # Test the permission_template is persisted and includes 2 access grants:
        # - 1 provides manage access to admin users
        # - 1 provides deposit access to registered users
        expect(admin_set.permission_template).to be_persisted
        expect(admin_set.permission_template.access_grants.count).to eq(2)

        # We're only loading the 'mediated_student_work_deposit' workflow,
        # but we need to make sure it's activated.
        expect(admin_set.active_workflow).to be_persisted
        expect(admin_set.active_workflow.name).to eq described_class::WORKFLOW_NAME

        expect(admin_set.read_groups).not_to include('public')
        expect(admin_set.edit_groups).to eq ['admin']
      end
    end

    context 'when the workflow configuration file does not exist' do
      before do
        allow(File)
          .to receive(:exist?)
          .with(Rails.root.join('config', 'workflows', "#{described_class::WORKFLOW_NAME}_workflow.json"))
          .and_return(false)
      end

      it 'raises an error' do
        expect { described_class.find_or_create_student_work_admin_set_id }
          .to raise_error(RuntimeError)
      end
    end
  end
end
