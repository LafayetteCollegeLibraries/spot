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
end
