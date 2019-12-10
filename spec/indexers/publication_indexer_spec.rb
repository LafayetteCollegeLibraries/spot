# frozen_string_literal: true
RSpec.describe PublicationIndexer do
  include_context 'indexing' do
    let(:mime_type) { 'application/pdf' }
    let(:mock_file) { instance_double(Hydra::PCDM::File) }
    let(:full_text_content) { "\n\n\n\nSome extracted full text\nfrom an article! \n\n" }
    let(:expected_results) { ["Some extracted full text\nfrom an article!"] }

    before do
      allow(file_set).to receive(:extracted_text).and_return(mock_file)
      allow(mock_file).to receive(:present?).and_return true
      allow(mock_file).to receive(:content).and_return(full_text_content)
    end
  end

  it_behaves_like 'a Spot indexer'

  it_behaves_like 'it indexes English-language dates'
  it_behaves_like 'it indexes a sortable date'

  describe 'storing full-text' do
    it "stores each file_set's full text content" do
      expect(solr_doc['extracted_text_tsimv']).to eq expected_results
    end
  end

  # simple_model_indexing just means that it maps the values
  # on the object (the keys) to the solr_doc fields (the values)
  {
    'title' => %w[title_tesim],
    'subtitle' => %w[subtitle_tesim],
    'title_alternative' => %w[title_alternative_tesim],
    'publisher' => %w[publisher_tesim publisher_sim],
    'source' => %w[source_tesim source_sim],
    'resource_type' => %w[resource_type_tesim resource_type_sim],
    'abstract' => %w[abstract_tesim],
    'description' => %w[description_tesim],
    'note' => %w[note_tesim],
    'bibliographic_citation' => %w[bibliographic_citation_tesim],
    'date_issued' => %w[date_issued_ssim],
    'date_available' => %w[date_available_ssim],
    'creator' => %w[creator_tesim creator_sim],
    'contributor' => %w[contributor_tesim contributor_sim],
    'academic_department' => %w[academic_department_tesim academic_department_sim],
    'division' => %w[division_tesim division_sim],
    'organization' => %w[organization_tesim organization_sim],
    'related_resource' => %w[related_resource_tesim related_resource_sim],
    'keyword' => %w[keyword_tesim keyword_sim],
    'license' => %w[license_tsm]
  }.each_pair do |method, solr_fields|
    describe method do
      let(:work_method) { method.to_sym }
      let(:solr_fields) { solr_fields }

      it_behaves_like 'simple model indexing'
    end
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

  describe 'subject' do
    let(:label) { 'Little free libraries' }
    let(:uri) { 'http://id.worldcat.org/fast/2004076' }
    let(:work) { build(:publication, subject: [RDF::URI(uri)]) }

    before do
      RdfLabel.first_or_create(uri: uri, value: label)
    end

    it 'stores the uri' do
      expect(solr_doc['subject_ssim']).to eq [uri]
    end

    it 'stores the label' do
      expect(solr_doc['subject_label_ssim']).to eq [label]
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

    let(:mock_file) { instance_double(Hydra::PCDM::File) }
    let(:full_text_content) { "\n\n\n\nSome extracted full text\nfrom an article! \n\n" }
    let(:expected_results) { ["Some extracted full text\nfrom an article!"] }

    it "stores each file_set's full text content" do
      expect(solr_doc['extracted_text_tsimv']).to eq expected_results
    end
  end
end
