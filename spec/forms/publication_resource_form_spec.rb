# frozen_string_literal: true
RSpec.describe PublicationResourceForm, valkyrization: true do
  it_behaves_like 'it supports local/standard identifiers'

  describe "#abstract" do
    let(:field) { :abstract }
    it_behaves_like 'a language-tagged resource field'
  end

  describe "#description" do
    let(:field) { :description }
    it_behaves_like 'a language-tagged resource field'
  end

  describe '#subject' do
    let(:field) { :subject }
    it_behaves_like 'a nested attribute field'
  end

  describe "#subtitle" do
    let(:field) { :subtitle }
    it_behaves_like 'a language-tagged resource field'
  end

  describe "#title" do
    let(:field) { :title }
    it_behaves_like 'a language-tagged resource field'
  end

  describe "#title_alternative" do
    let(:field) { :title_alternative }
    it_behaves_like 'a language-tagged resource field'
  end
end
