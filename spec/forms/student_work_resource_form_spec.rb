# frozen_string_literal: true
RSpec.describe StudentWorkResourceForm, valkyrization: true do
  subject(:form) { described_class.new(resource) }
  let(:resource) { build(:student_work_resource) }

  it_behaves_like 'it supports local/standard identifiers'
  it_behaves_like 'it includes Hyrax::FormFields', schema: :core_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :base_metadata, except: [:description]
  it_behaves_like 'it includes Hyrax::FormFields', schema: :student_work_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :institutional_metadata
  it_behaves_like 'it validates EDTF date fields', fields: [:date]

  describe 'singular fields' do
    %w[abstract date date_available description].each do |field|
      describe "##{field}" do
        it 'is singular' do
          expect(described_class.definitions[field][:multiple]).to be false
          expect(described_class.definitions[field][:default].call).to be nil
        end
      end
    end
  end

  describe 'controlled vocabulary fields' do
    describe '#location' do
      let(:field) { :location }
      it_behaves_like 'a controlled vocabulary field', class: Spot::ControlledVocabularies::Location
    end

    describe '#subject' do
      let(:field) { :subject }
      it_behaves_like 'a controlled vocabulary field', class: Spot::ControlledVocabularies::AssignFastSubject
    end

    describe '#language' do
      let(:field) { :language }
      it_behaves_like 'a controlled vocabulary field'
    end

    describe '#academic_department' do
      let(:field) { :academic_department }
      it_behaves_like 'a controlled vocabulary field'
    end

    describe '#advisor' do
      let(:field) { :advisor }
      it_behaves_like 'a controlled vocabulary field'
    end

    describe '#division' do
      let(:field) { :division }
      it_behaves_like 'a controlled vocabulary field'
    end
  end
end
