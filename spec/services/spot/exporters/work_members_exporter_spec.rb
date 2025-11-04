# frozen_string_literal: true
#
# Is this too much mocking? I didn't want to go down the rabbit hole
# of generating a full item just for this spec.
RSpec.describe Spot::Exporters::WorkMembersExporter, perform_enqueued: true do
  subject(:exporter) { described_class.new(solr_document) }

  let(:solr_document) { instance_double(SolrDocument, file_set_ids: ['abc123']) }
  let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'image.png') }
  let(:path_to_transcript) { Rails.root.join('spec', 'fixtures', 'transcript.vtt') }
  let(:file) do
    instance_double(Hydra::PCDM::File,
                    stream: [File.read(path_to_file)],
                    file_name: ['test-image.png'])
  end
  let(:transcript) do
    instance_double(Hydra::PCDM::File,
                    stream: [File.read(path_to_file)],
                    file_name: ['test-transcript.vtt'])
  end
  let(:destination) { '/tmp/spot-work_members_exporter_spec' }

  before do
    allow(ActiveFedora::Base).to receive(:find).with(['abc123']).and_return([file_set])
    allow(file_set).to receive(:is_a?).with(FileSet).and_return true
    FileUtils.mkdir_p(destination)
  end

  context 'the fileset has a transcript' do
    let(:file_set) { instance_double(FileSet, original_file: file, transcript: transcript) }

    describe '#files' do
      subject { exporter.files }

      it { is_expected.to match_array([file, transcript]) }
    end

    describe '#export!' do
      let(:expected_file_1) { File.join(destination, 'test-image.png') }
      let(:expected_file_2) { File.join(destination, 'test-transcript.vtt') }

      before { exporter.export!(destination: destination) }
      after { FileUtils.rm_r(destination) }

      it 'writes the file to the destination' do
        expect(File.exist?(expected_file_1)).to be true
        expect(File.exist?(expected_file_2)).to be true
      end
    end
  end

  context 'the fileset does not have a transcript' do
    let(:file_set) { instance_double(FileSet, original_file: file) }

    describe '#files' do
      subject { exporter.files }

      it { is_expected.to match_array([file]) }
    end

    describe '#export!' do
      let(:expected_file_1) { File.join(destination, 'test-image.png') }

      before { exporter.export!(destination: destination) }
      after { FileUtils.rm_r(destination) }

      it 'writes the file to the destination' do
        expect(File.exist?(expected_file_1)).to be true
      end
    end
  end
end
