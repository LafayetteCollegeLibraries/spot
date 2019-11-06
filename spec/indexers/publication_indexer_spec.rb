# frozen_string_literal: true
RSpec.describe PublicationIndexer do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:work) { build(:publication) }
  let(:indexer) { described_class.new(work) }

  it_behaves_like 'it indexes English-language dates'
  it_behaves_like 'it indexes ISO language and label'
  it_behaves_like 'it indexes a sortable date'
  it_behaves_like 'it indexes a permalink'

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
    let(:fields) { %w[resource_type_tesim resource_type_sim] }
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

  describe 'note' do
    # :stored_searchable
    let(:fields) { %w[note_tesim] }
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
    let(:fields) { %w[date_issued_ssim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'date_available' do
    # :symbol, :facetable
    let(:fields) { %w[date_available_ssim] }
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
    # :stored_searchable, :facetable
    let(:fields) { %w[academic_department_tesim academic_department_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'division' do
    # :symbol, :facetable
    let(:fields) { %w[division_tesim division_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'organization' do
    # :symbol, :facetable
    let(:fields) { %w[organization_tesim organization_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'related_resource' do
    # :symbol
    let(:fields) { %w[related_resource_tesim related_resource_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'keyword' do
    # :symbol, :facetable
    let(:fields) { %w[keyword_tesim keyword_sim] }
    it_behaves_like 'simple model indexing'
  end

  describe 'subject' do
    # :stored_searchable, :facetable
    let(:fields) { %w[subject_tesim subject_sim] }
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

  describe 'location' do
    let(:label) { 'Easton, PA' }
    let(:uri) { 'http://sws.geonames.org/5188140/' }
    let(:work) { build(:publication, location: [RDF::URI(uri)]) }

    before do
      RdfLabel.first_or_create(uri: uri, value: label)
    end

    it 'stores the uri' do
      expect(solr_doc['location_ssim']).to eq [uri]
    end

    it 'stores the label' do
      expect(solr_doc['location_label_ssim']).to eq [label]
    end
  end

  describe 'years_encompassed' do
    let(:work) { build(:publication, date_issued: ['1986-02-11', '2019-01-11']) }
    let(:years) { [1986, 2019] }

    it 'parses years from date_issued' do
      expect(solr_doc['years_encompassed_iim']).to include(*years)
    end
  end

  describe 'storing full-text' do
    before do
      allow(work).to receive(:file_sets).and_return([file_set])
      allow(file_set).to receive(:extracted_text).and_return(mock_file)
      allow(mock_file).to receive(:present?).and_return true
      allow(mock_file).to receive(:content).and_return(full_text_content)
    end

    let(:file_set) { instance_double(FileSet) }
    let(:mock_file) { instance_double(Hydra::PCDM::File) }
    let(:full_text_content) { "\n\n\n\nSome extracted full text\nfrom an article! \n\n" }
    let(:expected_results) { ["Some extracted full text\nfrom an article!"] }

    it "stores each file_set's full text content" do
      expect(solr_doc['extracted_text_tsimv']).to eq expected_results
    end
  end

  describe 'title sort' do
    it 'indexes the first title, downcased' do
      expect(solr_doc['title_sort_si']).to eq work.title.first.to_s.downcase
    end
  end
end
