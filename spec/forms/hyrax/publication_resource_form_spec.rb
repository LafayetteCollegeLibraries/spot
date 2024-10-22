# frozen_string_literal: true
RSpec.describe Hyrax::PublicationResourceForm do
  subject(:form) { described_class.new(resource) }
  let(:resource) { build(:publication_resource) }

  [:abstract, :description, :subtitle, :title, :title_alternative].each do |language_tagged_field|
    describe "##{language_tagged_field}" do
      let(:field) { language_tagged_field }
      it_behaves_like 'a language-tagged resource field'
    end
  end
end
