# frozen_string_literal: true
RSpec.shared_examples 'a Spot indexer' do
  # need to include the context here because, while the context is available
  # to shared_examples when the host group includes the context,
  # being able to manipulate the values deson't seem to work unless
  # the context is included here.
  include_context 'indexing'

  it_behaves_like 'it indexes a permalink'
  it_behaves_like 'it indexes ISO language and label'

  describe 'identifiers' do
    let(:attributes) { { identifier: identifier } }

    context 'when identifier is empty' do
      let(:identifier) { [] }

      it 'does nothing' do
        expect(solr_doc['identifier_standard_ssim']).to eq []
        expect(solr_doc['identifier_local_ssim']).to eq []
      end
    end

    context 'when local identifier is present' do
      let(:identifier) { ['lafayette:abc123'] }

      it 'indexes the value to the "identifier_local_ssim" field' do
        expect(solr_doc['identifier_local_ssim']).to eq ['lafayette:abc123']
        expect(solr_doc['identifier_standard_ssim']).to eq []
      end
    end

    context 'when a standard identifeir is present' do
      let(:identifier) { ['issn:1234-5678'] }

      it 'indexes the value to the "identifier_standard_ssim" field' do
        expect(solr_doc['identifier_standard_ssim']).to eq ['issn:1234-5678']
        expect(solr_doc['identifier_local_ssim']).to eq []
      end
    end

    context 'when both types of identifiers are present' do
      let(:identifier) { ['issn:1234-5678', 'lafayette:abc123'] }

      it 'indexes both to their respsective fields' do
        expect(solr_doc['identifier_standard_ssim']).to eq ['issn:1234-5678']
        expect(solr_doc['identifier_local_ssim']).to eq ['lafayette:abc123']
      end
    end
  end

  describe 'rights statements' do
    let(:attributes) { { rights_statement: [uri] } }
    let(:uri) { 'http://rightsstatements.org/vocab/NKC/1.0/' }
    let(:label) { 'No Known Copyright' }
    let(:shortcode) { 'NKC' }

    it 'indexes the uri' do
      expect(solr_doc['rights_statement_ssim']).to eq [uri]
    end

    it 'indexes the label' do
      expect(solr_doc['rights_statement_label_ssim']).to eq [label]
    end

    it 'indexes the shortcode' do
      expect(solr_doc['rights_statement_shortcode_ssim']).to eq [shortcode]
    end

    context 'when an unknown uri is present' do
      let(:uri) { 'http://nope-nothing-here.org' }

      it 'uses the uri as the label' do
        expect(solr_doc['rights_statement_label_ssim']).to eq [uri]
      end

      it 'indexes the shortcode as nil' do
        expect(solr_doc['rights_statement_shortcode_ssim']).to eq [nil]
      end
    end

    context 'when the URI is an ActiveTriples::Resrouce' do
      let(:uri) { ActiveTriples::Resource.new('http://rightsstatements.org/vocab/NKC/1.0/') }

      it 'uses the #id value' do
        expect(solr_doc['rights_statement_ssim']).to eq uri.id
      end
    end
  end

  describe 'sortable title' do
    it 'indexes the first title, downcased' do
      expect(solr_doc['title_sort_si']).to eq work.title.first.to_s.downcase
    end
  end

  describe 'storing file formats' do
    let(:file_set) { instance_double(FileSet, id: 'fs123def4') }
    let(:mime_type) { 'text/plain' }

    before do
      allow(work).to receive(:file_sets).and_return([file_set])
      allow(file_set).to receive(:mime_type).and_return(mime_type)
    end

    it 'stores the formats of the file_sets' do
      expect(solr_doc['file_format_ssim']).to eq [mime_type]
    end
  end

  describe 'storing thumbnails' do
    it 'stores the full url of a thumbnail' do
      expect(solr_doc['thumbnail_url_ss']).to eq "http://localhost#{thumbnail_path}"
    end
  end
end
