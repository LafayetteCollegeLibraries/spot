# frozen_string_literal: true
RSpec.describe Spot::IndexesCitationMetadata do
  subject(:solr_doc) { indexer.generate_solr_document }

  describe 'extracting citation metadata' do
    let(:work) { build(:publication, bibliographic_citation: ['Last, First. "Title." Journal 1.2 (2000): 1-2.']) }

    it 'extracts metadata' do
      expect(solr_doc['citation_journal_title_ss']).to eq 'Title'
      expect(solr_doc['citation_volume_ss']).to eq '1'
      expect(solr_doc['citation_issue_ss']).to eq '2'
      expect(solr_doc['citation_firstpage_ss']).to eq '1'
      expect(solr_doc['citation_lastpage_ss']).to eq '2'
    end
  end

  describe 'incomplete citation metadata' do
    let(:work) { build(:publication, bibliographic_citation: ['Last, First. "Title." Journal 1.2 (2000)']) }

    it 'extracts metadata' do
      expect(solr_doc['citation_journal_title_ss']).to eq 'Title'
      expect(solr_doc['citation_volume_ss']).to eq '1'
      expect(solr_doc['citation_issue_ss']).to eq '2'
      expect(solr_doc['citation_firstpage_ss']).to eq ''
      expect(solr_doc['citation_lastpage_ss']).to eq ''
    end
  end

  describe 'no citation metadata' do
    let(:work) { build(:publication, bibliographic_citation: ['']) }

    it 'extracts metadata' do
      expect(solr_doc['citation_journal_title_ss']).to eq ''
      expect(solr_doc['citation_volume_ss']).to eq ''
      expect(solr_doc['citation_issue_ss']).to eq ''
      expect(solr_doc['citation_firstpage_ss']).to eq ''
      expect(solr_doc['citation_lastpage_ss']).to eq ''
    end
  end
end
