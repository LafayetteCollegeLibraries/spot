# frozen_string_literal: true
require 'fileutils'

# Is this too much mocking? I didn't want to go down the rabbit hole
# of generating a full item just for this spec.
RSpec.describe Spot::Exporters::WorkMembersExporter, perform_enqueued: true do
  subject(:exporter) { described_class.new(solr_document) }

  let(:solr_document) { instance_double(SolrDocument, file_set_ids: ['abc123']) }
  let(:file_set) { instance_double(FileSet, original_file: file) }
  let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'image.png') }
  let(:file) do
    instance_double(Hydra::PCDM::File,
                    stream: [File.read(path_to_file)],
                    file_name: ['test-image.png'])
  end
  let(:destination) { '/tmp/spot-work_members_exporter_spec' }

  before do
    allow(ActiveFedora::Base).to receive(:find).with(['abc123']).and_return([file_set])
    allow(file_set).to receive(:is_a?).with(FileSet).and_return true
    FileUtils.mkdir_p(destination)
  end

  describe '#export!' do
    let(:expected_file) { File.join(destination, 'test-image.png') }

    before { exporter.export!(destination: destination) }
    after { FileUtils.rm_r(destination) }

    it 'writes the file to the destination' do
      expect(File.exist?(expected_file)).to be true
    end
  end
end
