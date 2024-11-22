# frozen_string_literal: true
RSpec.describe StudentWorkResourceForm, valkyrization: true do
  subject(:form) { described_class.new(resource) }
  let(:resource) { build(:student_work_resource) }

  it_behaves_like 'it supports local/standard identifiers'
  it_behaves_like 'it includes Hyrax::FormFields', schema: :core_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :base_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :student_work_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :institutional_metadata

  describe 'nested attribute fields' do
    describe '#subject' do
      let(:field) { :subject }
      it_behaves_like 'a nested attribute field'
    end

    describe '#language' do
      let(:field) { :language }
      it_behaves_like 'a nested attribute field'
    end

    describe '#academic_department' do
      let(:field) { :academic_department }
      it_behaves_like 'a nested attribute field'
    end

    describe '#advisor' do
      let(:field) { :advisor }
      it_behaves_like 'a nested attribute field'
    end

    describe '#division' do
      let(:field) { :division }
      it_behaves_like 'a nested attribute field'
    end
  end
end
