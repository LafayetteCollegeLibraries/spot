# frozen_string_literal: true
require 'fileutils'

RSpec.describe Spot::Exporters::WorkMetadataExporter do
  let(:exporter) { described_class.new(work, ability, request) }

  let(:work) { create(:publication, title: ['cool beans']) }
  let(:ability) { Ability.new(nil) }
  let(:request) { instance_double(ActionDispatch::Request, host: 'localhost') }
  let(:destination) { '/tmp/spot-work_metadata_exporter_spec' }
  let(:attributes) { { title: ['cool beans'] } }
  let(:solr_doc) { SolrDocument.find(work.id) }

  before do
    FileUtils.mkdir_p(destination)
    ActiveFedora::Fedora.reset!
  end
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
    let(:graph) { Hyrax::GraphExporter.new(solr_doc, request).fetch }
    let(:output) { graph.dump(format, *args) }
    let(:args) { {} }
    let(:object_url) { "http://localhost/concern/publications/#{work.id}"}

    context 'when requesting ttl' do
      let(:format) { :ttl }
      let(:title_ttl) do
        %(<http://purl.org/dc/terms/title> "#{work.title.first}";)
      end

      it 'saves the file as <id>.ttl' do
        expect(File.exist?(expected_output_file)).to be true
      end

      it { is_expected.to start_with "<#{object_url}> a"}
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

      it 'contains @id' do
        expect(parsed['@id']).to eq object_url
      end

      it do
        expect(parsed['dc:title']).to eq work.title.first
      end
    end

    context 'when requesting all formats' do
      subject { Dir["#{destination}/*"].map { |f| File.basename(f) } }

      let(:format) { :all }
      let(:id) { work.id }
      let(:files) { %w[nt ttl jsonld].map { |ext| "#{id}.#{ext}" } }

      it { is_expected.to include(*files) }
    end
  end
end
