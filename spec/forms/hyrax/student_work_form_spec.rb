# frozen_string_literal: true
RSpec.describe Hyrax::StudentWorkForm do
  before do
    allow(AdminSet).to receive(:find_or_create_default_admin_set_id).and_return(AdminSet::DEFAULT_ID)
    allow(Sipity::Workflow)
      .to receive(:where)
      .with(name: anything)
      .and_return(workflow_relation)
    allow(workflow_relation)
      .to receive(:order)
      .with(anything)
      .and_return(workflow_results)
  end

  let(:workflow_relation) { instance_double('Sipity::Workflow::ActiveRecord_Relation') }
  let(:workflow_results) { [] }

  it_behaves_like 'a Spot work form'

  it_behaves_like 'it handles required fields',
                  :title, :creator, :advisor, :academic_department, :division,
                  :description, :date, :date_available, :rights_statement, :resource_type

  describe '.terms' do
    subject { described_class.terms }

    describe 'includes optional fields' do
      it { is_expected.to include :abstract }
      it { is_expected.to include :language }
      it { is_expected.to include :related_resource }
      it { is_expected.to include :access_note }
      it { is_expected.to include :organization }
      it { is_expected.to include :subject }
      it { is_expected.to include :keyword }
      it { is_expected.to include :bibliographic_citation }
      it { is_expected.to include :standard_identifier }
      it { is_expected.to include :note }
    end
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }

    it { is_expected.to include(:title) }
    it { is_expected.to include(creator: []) }
    it { is_expected.to include(advisor: []) }
    it { is_expected.to include(academic_department: []) }
    it { is_expected.to include(division: []) }
    it { is_expected.to include(:description) }
    it { is_expected.to include(:date) }
    it { is_expected.to include(:date_available) }
    it { is_expected.to include(:rights_statement) }
    it { is_expected.to include(resource_type: []) }
    it { is_expected.to include(:abstract) }
    it { is_expected.to include(language: []) }
    it { is_expected.to include(related_resource: []) }
    it { is_expected.to include(access_note: []) }
    it { is_expected.to include(organization: []) }
    it { is_expected.to include(subject: []) }
    it { is_expected.to include(keyword: []) }
    it { is_expected.to include(bibliographic_citation: []) }
    it { is_expected.to include(standard_identifier_prefix: [], standard_identifier_value: []) }
    it { is_expected.to include(note: []) }
  end

  describe '.multiple?' do
    it 'marks singular fields as false' do
      [:title, :description, :date, :date_available, :abstract].each do |f|
        expect(described_class.multiple?(f)).to be false
      end
    end
  end

  describe '.model_attributes' do
    subject(:attributes) { described_class.model_attributes(raw_params) }

    let(:raw_params) { ActionController::Parameters.new(params) }
    let(:params) { {} }

    describe 'handles nested attributes' do
      describe 'language' do
        let(:field) { 'language' }

        it_behaves_like 'it transforms a local vocabulary attribute'
      end

      describe 'academic_department' do
        let(:field) { 'academic_department' }

        it_behaves_like 'it transforms a local vocabulary attribute'
      end

      describe 'division' do
        let(:field) { 'division' }

        it_behaves_like 'it transforms a local vocabulary attribute'
      end
    end

    describe 'admin_set_id' do
      before do
        allow(Hyrax::PermissionTemplate)
          .to receive(:find_by)
          .with(source_id: admin_set_id)
          .and_return(permission_template)
        allow(permission_template)
          .to receive(:active_workflow)
          .and_return(workflow)
      end

      let(:workflow_results) { [workflow] }
      let(:workflow) { instance_double('Sipity::Workflow', permission_template: permission_template, allows_access_grant?: false) }
      let(:permission_template) { instance_double('Hyrax::PermissionTemplate', admin_set: admin_set) }
      let(:admin_set) { instance_double('AdminSet', id: admin_set_id) }
      let(:admin_set_id) { 'abc123def' }

      context 'when a value is present' do
        let(:params) { { 'admin_set_id' => admin_set_id } }
        let(:admin_set_id) { 'admin_set_id_value' }

        it 'retains the value' do
          # { 'admin_set_id' => 'admin_set_id_value' }
          expect(attributes[:admin_set_id]).to eq admin_set_id
        end
      end

      context 'when a value is not present' do
        context 'when the expected workflow exists' do
          it 'uses the admin_set assigned to the workflow' do
            # { 'admin_set_id' => 'abc123def' }
            expect(attributes[:admin_set_id]).to eq admin_set.id
          end
        end

        context 'when the workflow does not exist' do
          let(:workflow_results) { [] }

          it 'uses the default admin_set id' do
            # { 'admin_set_id' => 'admin_set/default' }
            expect(attributes[:admin_set_id]).to eq AdminSet::DEFAULT_ID
          end
        end
      end
    end
  end
end
