# frozen_string_literal: true
RSpec.describe Hyrax::PublicationForm do
  it_behaves_like 'a Spot work form'

  shared_context 'required fields' do
    it 'contains required fields' do
      expect(terms).to include :title, :date_issued, :resource_type, :rights_statement
    end
  end

  describe '.required_fields' do
    subject(:terms) { described_class.required_fields }

    include_context 'required fields'
  end

  describe '.terms' do
    subject(:terms) { described_class.terms }

    include_context 'required fields'

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

  describe '.primary_terms form hints' do
    described_class.new(Publication.new, nil, nil).primary_terms.each do |term|
      describe "for #{term}" do
        subject do
          I18n.t("simple_form.hints.defaults.#{term}", locale: :en, default: nil)
        end

        it { is_expected.not_to be_nil, "Hint missing for Publication##{term}" }
      end
    end
  end

  describe '.build_permitted_params' do
    subject(:params) { described_class.build_permitted_params }

    # rubocop:disable RSpec/ExampleLength
    it 'includes permitted fields' do
      expect(params).to include(:title)
      expect(params).to include(rights_holder: [])
      expect(params).to include(subtitle: [])
      expect(params).to include(title_alternative: [])
      expect(params).to include(creator: [])
      expect(params).to include(contributor: [])
      expect(params).to include(editor: [])
      expect(params).to include(publisher: [])
      expect(params).to include(source: [])
      expect(params).to include(academic_department: [])
      expect(params).to include(division: [])
      expect(params).to include(organization: [])
      expect(params).to include(:abstract)
      expect(params).to include(description: [])
      expect(params).to include(note: [])
      expect(params).to include(:date_issued)
      expect(params).to include(resource_type: [])
      expect(params).to include(physical_medium: [])
      expect(params).to include(language: [])
      expect(params).to include(keyword: [])
      expect(params).to include(bibliographic_citation: [])
      expect(params).to include(standard_identifier: [])
      expect(params).to include(local_identifier: [])
      expect(params).to include(related_resource: [])
      expect(params).to include(:rights_statement)
      expect(params).to include(:representative_id)
      expect(params).to include(:thumbnail_id)
      expect(params).to include(rendering_ids: [])
      expect(params).to include(files: [])
      expect(params).to include(:visibility_during_embargo)
      expect(params).to include(:embargo_release_date)
      expect(params).to include(:visibility_after_embargo)
      expect(params).to include(:visibility_during_lease)
      expect(params).to include(:lease_expiration_date)
      expect(params).to include(:visibility_after_lease)
      expect(params).to include(:visibility)
      expect(params).to include(ordered_member_ids: [])
      expect(params).to include(in_works_ids: [])
      expect(params).to include(member_of_collection_ids: [])
      expect(params).to include(:admin_set_id)
      expect(params).to include(permissions_attributes: [:type, :name, :access, :id, :_destroy])
      expect(params).to include(:on_behalf_of)
      expect(params).to include(:version)
      expect(params).to include(:add_works_to_collection)
      expect(params).to include(
        based_near_attributes: [:id, :_destroy],
        member_of_collections_attributes: [:id, :_destroy],
        work_members_attributes: [:id, :_destroy]
      )
      expect(params).to include(standard_identifier_prefix: [], standard_identifier_value: [])
      expect(params).to include(local_identifier: [])
      expect(params).to include(:title_value)
      expect(params).to include(:title_language)
      expect(params).to include(title_alternative_value: [], title_alternative_language: [])
      expect(params).to include(subtitle_value: [], subtitle_language: [])
      expect(params).to include(:abstract_value)
      expect(params).to include(:abstract_language)
      expect(params).to include(description_value: [], description_language: [])
      expect(params).to include(language_attributes: [:id, :_destroy])
      expect(params).to include(academic_department_attributes: [:id, :_destroy])
      expect(params).to include(division_attributes: [:id, :_destroy])
      expect(params).to include(location_attributes: [:id, :_destroy])
      expect(params).to include(subject_attributes: [:id, :_destroy])
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
