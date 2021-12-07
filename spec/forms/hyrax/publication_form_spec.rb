# frozen_string_literal: true
RSpec.describe Hyrax::PublicationForm do
  it_behaves_like 'a Spot work form'
  it_behaves_like 'it handles required fields', :title, :date_issued, :resource_type, :rights_statement

  describe '.terms' do
    subject(:terms) { described_class.terms }

    describe 'includes optional fields' do
      it { is_expected.to include :rights_holder }
      it { is_expected.to include :subtitle }
      it { is_expected.to include :title_alternative }
      it { is_expected.to include :publisher }
      it { is_expected.to include :source }
      it { is_expected.to include :abstract }
      it { is_expected.to include :description }
      it { is_expected.to include :note }
      it { is_expected.to include :standard_identifier }
      it { is_expected.to include :local_identifier }
      it { is_expected.to include :bibliographic_citation }
      it { is_expected.to include :creator }
      it { is_expected.to include :contributor }
      it { is_expected.to include :editor }
      it { is_expected.to include :academic_department }
      it { is_expected.to include :division }
      it { is_expected.to include :organization }
      it { is_expected.to include :keyword }
      it { is_expected.to include :subject }
    end
  end

  describe '.multiple?' do
    it 'marks singular fields as false' do
      %w[abstract date_issued date_available date_created title].each do |f|
        expect(described_class.multiple?(f)).to be false
      end
    end
  end

  describe '.model_attributes' do
    subject(:attributes) { described_class.model_attributes(raw_params) }

    let(:raw_params) { ActionController::Parameters.new(params) }

    context 'handles nested attributes' do
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

    context 'parses *_value and *_language into tagged RDF::Literals' do
      %w[title abstract].each do |field_name|
        context field_name do
          let(:field) { field_name }

          it_behaves_like 'a parsed language-tagged literal (single)'
        end
      end

      %w[title_alternative subtitle description].each do |field_name|
        context field_name do
          let(:field) { field_name }

          it_behaves_like 'a parsed language-tagged literal (multiple)'
        end
      end
    end
  end

  describe '.build_permitted_params' do
    subject(:params) { described_class.build_permitted_params }

    it { is_expected.to include(:title) }
    it { is_expected.to include(rights_holder: []) }
    it { is_expected.to include(subtitle: []) }
    it { is_expected.to include(title_alternative: []) }
    it { is_expected.to include(creator: []) }
    it { is_expected.to include(contributor: []) }
    it { is_expected.to include(editor: []) }
    it { is_expected.to include(publisher: []) }
    it { is_expected.to include(source: []) }
    it { is_expected.to include(academic_department: []) }
    it { is_expected.to include(division: []) }
    it { is_expected.to include(organization: []) }
    it { is_expected.to include(:abstract) }
    it { is_expected.to include(description: []) }
    it { is_expected.to include(note: []) }
    it { is_expected.to include(:date_issued) }
    it { is_expected.to include(resource_type: []) }
    it { is_expected.to include(physical_medium: []) }
    it { is_expected.to include(language: []) }
    it { is_expected.to include(keyword: []) }
    it { is_expected.to include(bibliographic_citation: []) }
    it { is_expected.to include(standard_identifier: []) }
    it { is_expected.to include(local_identifier: []) }
    it { is_expected.to include(related_resource: []) }
    it { is_expected.to include(:rights_statement) }
    it {
      is_expected.to include(based_near_attributes: [:id, :_destroy],
                             member_of_collections_attributes: [:id, :_destroy],
                             work_members_attributes: [:id, :_destroy])
    }
    it { is_expected.to include(standard_identifier_prefix: [], standard_identifier_value: []) }
    it { is_expected.to include(:title_value, :title_language) }
    it { is_expected.to include(title_alternative_value: [], title_alternative_language: []) }
    it { is_expected.to include(subtitle_value: [], subtitle_language: []) }
    it { is_expected.to include(:abstract_value, :abstract_language) }
    it { is_expected.to include(description_value: [], description_language: []) }
    it { is_expected.to include(language_attributes: [:id, :_destroy]) }
    it { is_expected.to include(academic_department_attributes: [:id, :_destroy]) }
    it { is_expected.to include(division_attributes: [:id, :_destroy]) }
    it { is_expected.to include(location_attributes: [:id, :_destroy]) }
    it { is_expected.to include(subject_attributes: [:id, :_destroy]) }
  end
end
