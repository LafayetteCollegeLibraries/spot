# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::CoreMetadata' do
  subject { described_class.new }

  describe 'metadata fields' do
    it do
      is_expected.to respond_to(:bibliographic_citation, :bibliographic_citation=)
      is_expected.to respond_to(:contributor, :contributor=)
      is_expected.to respond_to(:description, :description=)
      is_expected.to respond_to(:identifier, :identifier=)
      is_expected.to respond_to(:keyword, :keyword=)
      is_expected.to respond_to(:location, :location=)
      is_expected.to respond_to(:note, :note=)
      is_expected.to respond_to(:physical_medium, :physical_medium=)
      is_expected.to respond_to(:publisher, :publisher=)
      is_expected.to respond_to(:related_resource, :related_resource=)
      is_expected.to respond_to(:resource_type, :resource_type=)
      is_expected.to respond_to(:rights_holder, :rights_holder=)
      is_expected.to respond_to(:rights_statement, :rights_statement=)
      is_expected.to respond_to(:source, :source=)
      is_expected.to respond_to(:source_identifier, :source_identifier=)
      is_expected.to respond_to(:subject, :subject=)
      is_expected.to respond_to(:subtitle, :subtitle=)
      is_expected.to respond_to(:title_alternative, :title_alternative=)
    end
  end
end
