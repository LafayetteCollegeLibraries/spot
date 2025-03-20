# frozen_string_literal: true
RSpec.describe AudioVisualResourceForm, valkyrization: true do
  subject(:form) { described_class.new(resource) }
  let(:resource) { build(:audio_visual_resource) }

  it_behaves_like 'a Spot resource form'
  it_behaves_like 'it supports local/standard identifiers'
  it_behaves_like 'it includes Hyrax::FormFields', schema: :core_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :base_metadata
  it_behaves_like 'it includes Hyrax::FormFields', schema: :audio_visual_metadata
  it_behaves_like 'it validates EDTF date fields', fields: [:date]

  describe 'language-tagged resource fields' do
    describe '#title' do
      let(:field) { :title }
      it_behaves_like 'a language-tagged resource field'
    end

    describe '#title_alternative' do
      let(:field) { :title_alternative }
      it_behaves_like 'a language-tagged resource field'
    end

    describe '#subtitle' do
      let(:field) { :subtitle }
      it_behaves_like 'a language-tagged resource field'
    end

    describe '#description' do
      let(:field) { :description }
      it_behaves_like 'a language-tagged resource field'
    end

    describe '#inscription' do
      let(:field) { :inscription }
      it_behaves_like 'a language-tagged resource field'
    end
  end

  describe 'controlled vocabulary fields' do
    describe '#language' do
      let(:field) { :language }
      it_behaves_like 'a controlled vocabulary field'
    end
  end

  describe '#primary_terms' do
    subject(:primary_terms) { described_class.primary_terms }

    describe 'includes fields' do
      it { is_expected.to include :title }
      it { is_expected.to include :date }
      it { is_expected.to include :resource_type }
      it { is_expected.to include :rights_statement }
      it { is_expected.to include :rights_holder }
      it { is_expected.to include :subtitle }
      it { is_expected.to include :title_alternative }
      it { is_expected.to include :date_associated }
      it { is_expected.to include :creator }
      it { is_expected.to include :contributor }
      it { is_expected.to include :publisher }
      it { is_expected.to include :source }
      it { is_expected.to include :standard_identifier }
      it { is_expected.to include :local_identifier }
      it { is_expected.to include :description }
      it { is_expected.to include :inscription }
      it { is_expected.to include :subject }
      it { is_expected.to include :keyword }
      it { is_expected.to include :language }
      it { is_expected.to include :physical_medium }
      it { is_expected.to include :original_item_extent }
      it { is_expected.to include :location }
      it { is_expected.to include :repository_location }
      it { is_expected.to include :note }
      it { is_expected.to include :related_resource }
      it { is_expected.to include :research_assistance }
      it { is_expected.to include :provenance }
      it { is_expected.to include :barcode }
    end
  end
end
