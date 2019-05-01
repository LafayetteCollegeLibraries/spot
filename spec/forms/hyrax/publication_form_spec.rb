# frozen_string_literal: true
RSpec.describe Hyrax::PublicationForm do
  shared_context 'required fields' do
    it 'contains required fields' do
      expect(terms).to include :title
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
      it { is_expected.to include :subtitle }
      it { is_expected.to include :title_alternative }
      it { is_expected.to include :publisher }
      it { is_expected.to include :source }
      it { is_expected.to include :resource_type }
      it { is_expected.to include :abstract }
      it { is_expected.to include :description }
      it { is_expected.to include :note }
      it { is_expected.to include :identifier }
      it { is_expected.to include :bibliographic_citation }
      it { is_expected.to include :date_issued }
      it { is_expected.to include :date_available }
      it { is_expected.to include :creator }
      it { is_expected.to include :contributor }
      it { is_expected.to include :editor }
      it { is_expected.to include :academic_department }
      it { is_expected.to include :division }
      it { is_expected.to include :organization }
      it { is_expected.to include :keyword }
      it { is_expected.to include :subject }
      it { is_expected.to include :rights_statement }
    end

    describe 'includes internal_form_fields' do
      it { is_expected.to include :representative_id }
      it { is_expected.to include :thumbnail_id }
      it { is_expected.to include :files }
      it { is_expected.to include :visibility_during_embargo }
      it { is_expected.to include :visibility_after_embargo }
      it { is_expected.to include :embargo_release_date }
      it { is_expected.to include :visibility_during_lease }
      it { is_expected.to include :visibility_after_lease }
      it { is_expected.to include :lease_expiration_date }
      it { is_expected.to include :visibility }
      it { is_expected.to include :ordered_member_ids }
      it { is_expected.to include :in_works_ids }
      it { is_expected.to include :member_of_collection_ids }
      it { is_expected.to include :admin_set_id }
    end
  end

  describe '.multiple?' do
    it 'marks singular fields as false' do
      %w[resource_type abstract issued available date_created title].each do |f|
        expect(described_class.multiple?(f)).to be false
      end
    end
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }

    it { is_expected.to be_an Array }
  end

  describe '.model_attributes' do
    subject(:attributes) { described_class.model_attributes(raw_params) }

    let(:raw_params) { ActionController::Parameters.new(params) }

    context 'when passed identifier_prefix and identifier_value' do
      let(:params) do
        {
          'identifier_prefix' => ['hdl'],
          'identifier_value' => ['abc/123']
        }
      end

      it 'parses out identifiers' do
        expect(attributes[:identifier]).to eq ['hdl:abc/123']
      end

      context 'when no identifiers are present' do
        let(:params) do
          {
            'identifier_prefix' => [],
            'identifier_value' => []
          }
        end

        it 'returns nil' do
          expect(attributes[:identifier]).to be_empty
        end
      end
    end

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
end
