RSpec.describe PublicationIndexer do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:work) { build(:publication) }
  let(:indexer) { described_class.new(work) }

  describe 'title' do
    # :stored_searchable
    let(:fields) { %w[title_tesim] }
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

  describe 'language' do
    {
      'it' => 'Italian',
      'es' => 'Spanish',
      'fr' => 'French',
      'de' => 'German',
      'en' => 'English',
      'ja' => 'Japanese',
      '!!' => 'Other'
    }.each_pair do |lang_iso, lang_translated|
      context "#{lang_iso} to #{lang_translated}" do
        let(:work) { build(:publication, language: [lang_iso]) }

        it { is_expected.to include 'language_ssim' }

        it 'stores the ISO value in language_ssim' do
          expect(solr_doc['language_ssim']).to eq [lang_iso]
        end

        it { is_expected.to include 'language_display_ssim' }

        it 'stores the translated value in language_display_ssim' do
          expect(solr_doc['language_display_ssim']).to eq [lang_translated]
        end
      end
    end
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
    let(:issn_value) { '1234-5678'}
    let(:issn) { "issn:#{issn_value}" }
    let(:isbn_value) { '978-12345-67890' }
    let(:isbn) { "isbn:#{isbn_value}" }
    let(:hdl_value) { '10385/10000' }
    let(:hdl) { "hdl:#{hdl_value}" }
    let(:identifiers) { [issn, isbn, hdl] }
    let(:work) { build(:publication, identifier: identifiers) }

    describe 'stores the raw identifiers in work#identifier' do
      let(:fields) { %w[identifier_ssim] }
      it_behaves_like 'simple model indexing'
    end

    it 'parses out each identifier and indexes' do
      expect(subject).to include 'identifier_issn_ssim'
      expect(subject['identifier_issn_ssim']).to eq [issn_value]
      expect(subject).to include 'identifier_isbn_ssim'
      expect(subject['identifier_isbn_ssim']).to eq [isbn_value]
      expect(subject).to include 'identifier_hdl_ssim'
      expect(subject['identifier_hdl_ssim']).to eq [hdl_value]
    end
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

  pending 'related_resource' do
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
    # :symbol, :facetable
    let(:fields) { %w[rights_statement_ssim rights_statement_sim] }
    it_behaves_like 'simple model indexing'
  end
end

