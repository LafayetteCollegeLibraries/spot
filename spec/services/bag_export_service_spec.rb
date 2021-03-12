# frozen_string_literal: true
RSpec.describe Spot::BagExportService do
  describe '.export' do
    let(:work) { create(:image_with_file_set, content: File.open(path_to_file), label: 'image.png') }
    let(:path_to_file) { Rails.root.join('spec', 'fixtures', 'image.png') }
    let(:tmpdir) { Dir.mktmpdir('bag_export_service_spec') }
    let(:expected_bag_glob) do
      %w[
        bag-info.txt
        bagit.txt
        data
        data/metadata-image-png.csv
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
      output_tar = Dir.glob("#{tmpdir}/ldr-#{work.id}-*.tar").first
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
