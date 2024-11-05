# frozen_string_literal: true
RSpec.describe ImageResourceForm, valkyrization: true do
  subject(:form) { described_class.new(resource) }
  let(:resource) { build(:image_resource) }

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