# frozen_string_literal: true
RSpec.describe Hyrax::StudentWorkForm do
  it_behaves_like 'a Spot work form'

  it_behaves_like 'it handles required fields', :title, :resource_type, :rights_statement

  describe '.terms' do
    subject { described_class.terms }

    describe 'includes optional fields' do
      it { is_expected.to include :title_alternative }
      it { is_expected.to include :creator }
      it { is_expected.to include :contributor }
      it { is_expected.to include :abstract }
      it { is_expected.to include :description }
      it { is_expected.to include :date }
      it { is_expected.to include :date_available }
      it { is_expected.to include :language }
      it { is_expected.to include :location }
      it { is_expected.to include :physical_medium }
      it { is_expected.to include :publisher }
      it { is_expected.to include :identifier }
      it { is_expected.to include :keyword }
      it { is_expected.to include :related_resource }
      it { is_expected.to include :resource_type }
      it { is_expected.to include :source }
      it { is_expected.to include :subject }
      it { is_expected.to include :subtitle }
      it { is_expected.to include :advisor }
      it { is_expected.to include :academic_department }
      it { is_expected.to include :division }
      it { is_expected.to include :organization }
      it { is_expected.to include :rights_holder }
      it { is_expected.to include :rights_statement }
      it { is_expected.to include :bibliographic_citation }
      it { is_expected.to include :access_note }
      it { is_expected.to include :note }
    end
  end

  describe '.build_permitted_params' do
    subject { described_class.build_permitted_params }

    it { is_expected.to include(:title) }
    it { is_expected.to include(title_alternative: []) }
    it { is_expected.to include(creator: []) }
    it { is_expected.to include(contributor: []) }
    it { is_expected.to include(abstract: []) }
    it { is_expected.to include(description: []) }
    it { is_expected.to include(date: []) }
    it { is_expected.to include(date_available: []) }
    it { is_expected.to include(language: []) }
    it { is_expected.to include(location: []) }
    it { is_expected.to include(physical_medium: []) }
    it { is_expected.to include(publisher: []) }
    it { is_expected.to include(identifier: []) }
    it { is_expected.to include(keyword: []) }
    it { is_expected.to include(related_resource: []) }
    it { is_expected.to include(resource_type: []) }
    it { is_expected.to include(source: []) }
    it { is_expected.to include(subject: []) }
    it { is_expected.to include(subtitle: []) }
    it { is_expected.to include(advisor: []) }
    it { is_expected.to include(academic_department: []) }
    it { is_expected.to include(division: []) }
    it { is_expected.to include(organization: []) }
    it { is_expected.to include(rights_holder: []) }
    it { is_expected.to include(:rights_statement) }
    it { is_expected.to include(bibliographic_citation: []) }
    it { is_expected.to include(access_note: []) }
    it { is_expected.to include(note: []) }
  end
end
