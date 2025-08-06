# frozen_string_literal: true
RSpec.describe PublicationResourceIndexer, valkyrization: true do
  let(:solr_document) { described_class.new(resource: resource).to_solr }
  let(:resource) { FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only) }

  it_behaves_like 'a BaseResourceIndexer'

  describe 'publication_metadata' do
    it_behaves_like 'it indexes', :abstract, to: ['abstract_tesim']
    it_behaves_like 'it indexes', :date_issued, to: ['date_issued_ssim']
    it_behaves_like 'it indexes', :date_available, to: ['date_available_ssim']
    it_behaves_like 'it indexes', :editor, to: ['editor_sim', 'editor_tesim']
    it_behaves_like 'it indexes', :license, to: ['license_tsm']
  end

  describe 'seasonal date indexing' do
    subject { solr_document['english_language_date_teim'] }
    let(:resource) { build(:publication_resource_with_required_fields_only, date_issued: [date]) }
    let(:indexer) { described_class.for(resource: resource) }
    let(:solr_document) { indexer.to_solr }

    context 'when the date is in the fall' do
      let(:date) { '2023-10-21' }
      it { is_expected.to eq ['Autumn 2023', 'Fall 2023', 'October 2023', 'Oct 2023'] }
    end

    context 'when the date is in the winter' do
      let(:date) { '1986-02-11' }
      it { is_expected.to eq ['Winter 1986', 'February 1986', 'Feb 1986'] }
    end

    context 'when the date is in the spring' do
      let(:date) { '2025-04-04' }
      it { is_expected.to eq ['Spring 2025', 'April 2025', 'Apr 2025'] }
    end

    context 'when the date is in the summer' do
      let(:date) { '2024-07' }
      it { is_expected.to eq ['Summer 2024', 'July 2024', 'Jul 2024'] }
    end
  end
end
