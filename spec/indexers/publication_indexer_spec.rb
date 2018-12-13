# frozen_string_literal: true
RSpec.describe PublicationIndexer do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:work) { build(:publication) }
  let(:indexer) { described_class.new(work) }

  describe 'title' do
    # :stored_searchable
    let(:fields) { %w[title_tesim] }
    let(:metadata) { { title: ['Title of work'] } }
    it_behaves_like 'simple model indexing'
  end

  describe 'subtitle' do
    # :stored_searchable
    let(:fields) { %w[subtitle_tesim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'title_alternative' do
    # :stored_searchable
    let(:fields) { %w[title_alternative_tesim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'publisher' do
    # :stored_searchable, :facetable
    let(:fields) { %w[publisher_tesim publisher_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'source' do
    # :stored_searchable, :facetable
    let(:fields) { %w[source_tesim source_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'resource_type' do
    # :symbol, :facetable
    let(:fields) { %w[resource_type_ssim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'abstract' do
    # :stored_searchable
    let(:fields) { %w[abstract_tesim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'description' do
    # :stored_searchable
    let(:fields) { %w[description_tesim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'identifier' do
    let(:fields) { %w[identifier_ssim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'bibliographic_citation' do
    # :stored_searchable
    let(:fields) { %w[bibliographic_citation_tesim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'date_issued' do
    # :symbol, :facetable
    let(:fields) { %w[date_issued_ssim date_issued_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'date_available' do
    # :symbol, :facetable
    let(:fields) { %w[date_available_ssim date_available_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'creator' do
    # :stored_searchable, :facetable
    let(:fields) { %w[creator_tesim creator_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'contributor' do
    # :stored_searchable, :facetable
    let(:fields) { %w[contributor_tesim contributor_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'academic_department' do
    # :symbol, :facetable
    let(:fields) { %w[academic_department_ssim academic_department_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'division' do
    # :symbol, :facetable
    let(:fields) { %w[division_ssim division_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'organization' do
    # :symbol, :facetable
    let(:fields) { %w[organization_ssim organization_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'related_resource' do
    # :symbol
    let(:fields) { %w[related_resource_ssim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'keyword' do
    # :symbol, :facetable
    let(:fields) { %w[keyword_ssim keyword_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'subject' do
    # :symbol, :facetable
    let(:fields) { %w[subject_ssim subject_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'license' do
    let(:fields) { %w[license_tsm] }
    it_behaves_like 'simple model indexing'
  end

  describe 'rights_statement' do
    it { is_expected.to include 'rights_statement_ssim' }
    it { is_expected.to include 'rights_statement_label_ssim' }
  end

  describe 'language' do
    it 'stores the 2-character ISO-639-1 value' do
      expect(solr_doc['language_ssim']).to eq ['en']
    end

    it 'stores the label value' do
      expect(solr_doc['language_label_ssim']).to eq ['English']
    end
  end

  describe 'based_near' do
    let(:label) { 'Easton, PA' }
    let(:uri) { 'http://sws.geonames.org/5188140/' }
    let(:work) { build(:publication, based_near: [RDF::URI(uri)]) }

    before do
      RdfLabel.first_or_create(uri: uri, value: label)
    end

    it 'stores the uri' do
      expect(solr_doc['based_near_ssim']).to eq [uri]
    end

    it 'stores the label' do
      expect(solr_doc['based_near_label_ssim']).to eq [label]
    end
  end
end
