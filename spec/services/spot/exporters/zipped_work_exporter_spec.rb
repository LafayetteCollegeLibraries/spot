# frozen_string_literal: true
require 'fileutils'

RSpec.describe Spot::Exporters::ZippedWorkExporter do
  let(:exporter) { described_class.new(work, request) }
  let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'image.png') }
  let(:ability) { Ability.new(nil) }
  let(:request) { instance_double(ActionDispatch::Request, host: 'localhost') }
  let(:destination) { '/tmp/spot-zipped_work_exporter_spec' }
  let(:work) do
    @work ||= create(:publication_with_file_set, content: File.open(path_to_file), label: 'image.png')
  end

  before do
    FileUtils.mkdir_p(destination)
    ActiveFedora::Fedora.reset!
  end

  after { FileUtils.rm_r(destination) }

  describe '#export!' do
    before do
      exporter.export!(destination: output_file, metadata_formats: formats)
      ::ZipService.new(src_path: output_file).unzip!(dest_path: unzipped_location)
    end

    # the default
    let(:formats) { :all }
    let(:metadata_files) { %w[nt ttl jsonld csv].map { |ext| "#{work.id}.#{ext}" } }
    let(:expected_entries) { metadata_files + ['files', 'files/image.png'] }
    let(:output_file) { File.join(destination, "#{work.id}.zip") }
    let(:unzipped_location) { File.join(destination, 'unzipped') }

    it 'creates a zip file at <work_id>.zip' do
      expect(File.exist?(output_file)).to be true
    end

    it 'includes all metadata formats + files' do
      expect(file_entries(unzipped_location)).to contain_exactly(*expected_entries)
    end

    context 'when no metadata files requested' do
      let(:formats) { nil }
      let(:expected_entries) { ['test-image.png'] }

      it 'zips only the file_sets' do
        expect(file_entries(unzipped_location)).to contain_exactly('image.png')
      end
    end
  end

  def file_entries(path)
    Dir[File.join(path, '**', '*')].map { |e| e.sub(path.to_s + '/', '') }
  end
end
