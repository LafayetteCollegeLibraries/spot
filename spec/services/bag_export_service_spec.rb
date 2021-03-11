# frozen_string_literal: true
RSpec.describe Spot::BagExportService do
  describe '.identifier_for' do
    subject { described_class.identifier_for(work, date: datestamp) }

    let(:work) { instance_double(Publication, id: 'abc123def', etag: 'W/"0000000000000000000000000000000000000000"', file_set_ids: [file_set.id]) }
    let(:file_set) { instance_double(FileSet, id: 'fsabc123d', etag: 'W/"1111111111111111111111111111111111111111"') }
    let(:digest) { '2a120d8d7143b4bbe25b22a9db9664e26dd83e76' }
    let(:datestamp) { '20210311T000000' }

    before do
      allow(Publication).to receive(:find).with(work.id).and_return(work)
      allow(FileSet).to receive(:find).with(file_set.id).and_return(file_set)
    end

    it { is_expected.to eq "ldr-#{work.id}-#{datestamp}-#{digest}" }
  end

  describe '.export' do
    let(:work) { create(:image_with_file_set, content: File.open(path_to_file), label: 'image.png') }
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'image.png') }
    let(:tmpdir) { Dir.mktmpdir('bag_export_service_spec') }
    let(:expected_bag_glob) do
      %w[
        bag-info.txt
        bagit.txt
        data
        data/metadata-image.png.csv
        data/files
        data/files/image.png
        data/metadata.csv
        manifest-sha256.txt
        tagmanifest-md5.txt
        tagmanifest-sha1.txt
      ].sort
    end

    before do
      described_class.export(work, to: tmpdir)
    end

    after do
      FileUtils.remove_entry(tmpdir)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'writes a valid bag' do
      output_tar = Dir.glob("#{tmpdir}/*.tar").first
      expect(output_tar).not_to be nil

      Dir.mktmpdir('writes_a_valid_bag') do |tmp|
        tar_io = File.open(output_tar, 'rb')
        bag_dir = File.join(tmp, 'spec-bag')

        Minitar.unpack(tar_io, bag_dir)
        expect(BagIt::Bag.new(bag_dir)).to be_valid

        Dir.chdir(bag_dir) { expect(Dir.glob('**/*')).to contain_exactly(*expected_bag_glob) }
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
