# frozen_string_literal: true
RSpec.describe Hyrax::AudioVisualForm do
  it_behaves_like 'a Spot work form'
  it_behaves_like 'it handles required fields', :title, :resource_type, :rights_statement

  describe '.terms' do
    subject(:terms) { described_class.terms }

    describe 'includes optional fields' do
      it { is_expected.to include :date }
      it { is_expected.to include :title_alternative }
      it { is_expected.to include :subtitle }
      it { is_expected.to include :date_associated }
      it { is_expected.to include :rights_holder }
      it { is_expected.to include :description }
      it { is_expected.to include :inscription }
      it { is_expected.to include :creator }
      it { is_expected.to include :contributor }
      it { is_expected.to include :publisher }
      it { is_expected.to include :keyword }
      it { is_expected.to include :subject }
      it { is_expected.to include :location }
      it { is_expected.to include :language }
      it { is_expected.to include :source }
      it { is_expected.to include :physical_medium }
      it { is_expected.to include :original_item_extent }
      it { is_expected.to include :repository_location }
      it { is_expected.to include :research_assistance }
      it { is_expected.to include :related_resource }
      it { is_expected.to include :local_identifier }
      it { is_expected.to include :note }
      it { is_expected.to include :provenance }
      it { is_expected.to include :barcode }
      it { is_expected.to include :premade_derivatives }
    end
  end

  describe '.build_permitted_params' do
    subject(:params) { described_class.build_permitted_params }

    it { is_expected.to include(:title) }
    it { is_expected.to include(resource_type: []) }
    it { is_expected.to include(:rights_statement) }
    it { is_expected.to include(date: []) }
    it { is_expected.to include(title_alternative: []) }
    it { is_expected.to include(subtitle: []) }
    it { is_expected.to include(date_associated: []) }
    it { is_expected.to include(rights_holder: []) }
    it { is_expected.to include(description: []) }
    it { is_expected.to include(inscription: []) }
    it { is_expected.to include(creator: []) }
    it { is_expected.to include(contributor: []) }
    it { is_expected.to include(publisher: []) }
    it { is_expected.to include(keyword: []) }
    it { is_expected.to include(subject: []) }
    it { is_expected.to include(location: []) }
    it { is_expected.to include(language: []) }
    it { is_expected.to include(source: []) }
    it { is_expected.to include(physical_medium: []) }
    it { is_expected.to include(original_item_extent: []) }
    it { is_expected.to include(repository_location: []) }
    it { is_expected.to include(research_assistance: []) }
    it { is_expected.to include(related_resource: []) }
    it { is_expected.to include(local_identifier: []) }
    it { is_expected.to include(note: []) }
    it { is_expected.to include(premade_derivatives: []) }
    it {
      is_expected.to include(based_near_attributes: [:id, :_destroy],
                             member_of_collections_attributes: [:id, :_destroy],
                             work_members_attributes: [:id, :_destroy])
    }
    it { is_expected.to include(:title_value, :title_language) }
    it { is_expected.to include(title_alternative_value: [], title_alternative_language: []) }
    it { is_expected.to include(subtitle_value: [], subtitle_language: []) }
    it { is_expected.to include(description_value: [], description_language: []) }
    it { is_expected.to include(inscription_value: [], inscription_language: []) }
    it { is_expected.to include(location_attributes: [:id, :_destroy]) }
    it { is_expected.to include(subject_attributes: [:id, :_destroy]) }
  end
end
