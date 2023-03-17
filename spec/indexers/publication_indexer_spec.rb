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

  # simple_model_indexing just means that it maps the values
  # on the object (the keys) to the solr_doc fields (the values)
  {
    'title' => %w[tesim],
    'subtitle' => %w[tesim],
    'title_alternative' => %w[tesim],
    'publisher' => %w[tesim sim],
    'source' => %w[tesim sim],
    'resource_type' => %w[tesim sim],
    'abstract' => %w[tesim],
    'description' => %w[tesim],
    'note' => %w[tesim],
    'bibliographic_citation' => %w[tesim],
    'date_issued' => %w[ssim],
    'date_available' => %w[ssim],
    'creator' => %w[tesim sim],
    'contributor' => %w[tesim sim],
    'academic_department' => %w[tesim sim],
    'division' => %w[tesim sim],
    'organization' => %w[tesim sim],
    'related_resource' => %w[tesim sim],
    'keyword' => %w[tesim sim],
    'license' => %w[tsm]
  }.each_pair do |method, suffixes|
    describe method do
      let(:work_method) { method.to_sym }
      let(:solr_fields) { suffixes.map { |suffix| "#{method}_#{suffix}" } }

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
      expect(solr_doc['location_label_tesim']).to eq [label]
    end
  end

  describe 'storing full-text' do
    it "stores each file_set's full text content" do
      expect(solr_doc['extracted_text_tsimv']).to eq expected_results
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
      expect(solr_doc['subject_label_tesim']).to eq [label]
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
