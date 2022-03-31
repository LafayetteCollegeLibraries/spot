# frozen_string_literal: true
RSpec.describe Spot::Derivatives::AccessMasterService do
  subject(:service) { described_class.new(file_set) }

  let(:file_set) { FileSet.new }
  let(:derivative_path) { '/path/to/a/fs-access.tif' }

  before do
    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'access.tif')
      .and_return("#{derivative_path}.access.tif")
  end

  describe '#cleanup_derivatives' do
    before do
      allow(File).to receive(:exist?).with(derivative_path).and_return true
      allow(FileUtils).to receive(:rm_f).with(derivative_path)
    end

    it 'rimrafs all of the paths provided' do
      service.cleanup_derivatives

      expect(FileUtils).to have_received(:rm_f).with(derivative_path)
    end
  end

  describe '#create_derivatives' do
    before do
      allow(MiniMagick::Tool::Convert).to receive(:new).and_yield(magick_commands)
      allow(FileUtils).to receive(:mkdir_p).with('/path/to/a')
    end

    let(:magick_commands) do
      [].tap do |arr|
        arr.define_singleton_method(:merge!) do |args|
          args.each { |arg| self << arg }
        end
      end
    end

    let(:expected_commands) do
      [
        '/path/to/file.jpg[0]',
        '-define', 'tiff:tile-geometry=128x128',
        '-compress', 'jpeg',
        'ptif:/path/to/a/fs-access.tif'
      ]
    end

    it 'sends imagemagick commands to MiniMagick' do
      service.create_derivatives('/path/to/file.jpg')

      expect(magick_commands).to eq(expected_commands)
    end
  end
end
