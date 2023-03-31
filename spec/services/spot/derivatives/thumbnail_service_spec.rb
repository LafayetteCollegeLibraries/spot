# frozen_string_literal: true
RSpec.describe Spot::Derivatives::ThumbnailService, derivatives: true do
  subject(:service) { described_class.new(file_set) }

  let(:file_set) { FileSet.new }
  let(:derivative_path) { '/path/to/a/fs-thumbnail.jpg' }

  before do
    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'thumbnail')
      .and_return(derivative_path)
  end

  describe '#cleanup_derivatives' do
    before do
      allow(FileUtils).to receive(:rm_f)
      allow(File).to receive(:exist?).with(derivative_path).and_return true
    end

    it 'calls rimraf on the #derivative_url' do
      service.cleanup_derivatives

      expect(FileUtils).to have_received(:rm_f).with(derivative_path)
    end
  end

  describe '#create_derivatives' do
    before do
      allow(MiniMagick::Tool::Convert).to receive(:new).and_yield(magick_commands)
      allow(FileUtils).to receive(:mkdir_p).with(File.dirname(derivative_path))
    end

    let(:magick_commands) do
      [].tap do |arr|
        arr.define_singleton_method(:merge!) do |args|
          args.each { |arg| self << arg }
        end
      end
    end

    let(:filename) { '/path/to/a/source/file.tif' }

    let(:expected_commands) do
      [
        "#{filename}[0]",
        '-colorspace', 'sRGB',
        '-flatten',
        '-resize', '200x150>',
        '-format', 'jpg',
        derivative_path
      ]
    end

    it 'sends imagemagick commands to MiniMagick' do
      service.create_derivatives(filename)

      expect(magick_commands).to eq(expected_commands)
    end
  end

  describe '#valid?' do
    subject { service.valid? }

    before { allow(file_set).to receive(:mime_type).and_return(fs_mime_type) }

    # valid mime_types
    ['image/tiff', 'application/vnd.ms-excel', 'video/mpeg', 'application/pdf'].each do |mime_type|
      context "when mime_type is #{mime_type}" do
        let(:fs_mime_type) { mime_type }

        it { is_expected.to be true }
      end
    end

    # invalid mime_types
    ['audio/wav'].each do |mime_type|
      context "when mime_type is #{mime_type}" do
        let(:fs_mime_type) { mime_type }

        it { is_expected.to be false }
      end
    end
  end
end
