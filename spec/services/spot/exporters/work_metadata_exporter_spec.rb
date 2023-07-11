# frozen_string_literal: true
require 'fileutils'

RSpec.describe Spot::Exporters::WorkMetadataExporter do
  let(:exporter) { described_class.new(solr_document, request) }
  let(:work_id) { 'spot-work_metadata_exporter_spec-obj' }
  let(:ability) { Ability.new(nil) }
  let(:request) { instance_double(ActionDispatch::Request, host: 'localhost') }
  let(:destination) { "/tmp/#{work_id}" }
  let(:solr_document) { SolrDocument.find(work.id) }
  let(:work) do
    Publication.find(work_id)
  rescue ActiveFedora::ObjectNotFoundError
    create(:publication, id: work_id, title: ['ok cool'])
  end

  before { FileUtils.mkdir_p(destination) }
  after { FileUtils.rm_r(destination) }

  describe '#export!' do
    subject(:content) do
      File.open(expected_output_file)
          .read
          .gsub(/\s+/, ' ')
          .strip
    end

    before { exporter.export!(destination: destination, format: format) }

    let(:expected_output_file) { File.join(destination, "#{work.id}.#{format}") }
    let(:object_url) { "http://localhost/concern/publications/#{work.id}" }

    context 'when requesting ttl' do
      let(:format) { :ttl }
      let(:title_ttl) do
        %(<http://purl.org/dc/terms/title> "#{work.title.first}";)
      end

      it 'saves the file as <id>.ttl' do
        expect(File.exist?(expected_output_file)).to be true
      end

      it { is_expected.to start_with "<#{object_url}> a" }
      it { is_expected.to include title_ttl }
    end

    context 'when requesting ntriples' do
      let(:format) { :nt }
      let(:title_nt) do
        %(<#{object_url}> <http://purl.org/dc/terms/title> "#{work.title.first}" .)
      end

      it 'saves the file as <id>.nt' do
        expect(File.exist?(expected_output_file)).to be true
      end

      it { is_expected.to include title_nt }
    end

    context 'when requesting jsonld' do
      subject(:parsed) { JSON.parse(content) }

      let(:format) { :jsonld }

      it 'saves the file as <id>.jsonld' do
        expect(File.exist?(expected_output_file)).to be true
      end

      it 'contains @id' do
        expect(parsed['@id']).to eq object_url
      end

      it do
        expect(parsed['dc:title']).to eq work.title.first
      end
    end

    context 'when requesting csv' do
      let(:content) { CSV.parse(File.open(expected_output_file)) }
      let(:format) { :csv }

      it 'saves as <id>.csv' do
        expect(File.exist?(expected_output_file)).to be true
      end

      it 'only writes two rows' do
        expect(content.size).to eq 2
      end

      it 'outputs the headers' do
        expect(content.first.join(',')).to start_with 'id,title'
      end

      it 'outputs the content' do
        expect(content.last.first).to eq work.id
      end
    end

    context 'when requesting all formats' do
      subject { Dir["#{destination}/*"].map { |f| File.basename(f) } }

      let(:format) { :all }
      let(:id) { work.id }
      let(:files) { %w[nt ttl jsonld csv].map { |ext| "#{id}.#{ext}" } }

      it { is_expected.to include(*files) }
    end
  end
end
