# frozen_string_literal: true
RSpec.describe Spot::FileSetAccessMasterService do
  subject(:service) { described_class.new(valid_file_set) }
  before do
    allow(valid_file_set).to receive(:mime_type).and_return('image/jpeg')
  end

  let(:valid_file_set) { FileSet.new }

  it_behaves_like 'a Hyrax::DerivativeService'

  describe '#cleanup_derivatives' do
    before do
      allow(Hyrax::DerivativePath)
        .to receive(:derivatives_for_reference)
        .with(valid_file_set)
        .and_return(derivative_paths)

      allow(FileUtils).to receive(:rm_f)
    end

    let(:derivative_paths) { ['/path/to/a/fs-thumbnail.png', '/path/to/a/fs-access_master.tif'] }

    it 'rimrafs all of the paths provided' do
      service.cleanup_derivatives

      expect(FileUtils)
        .to have_received(:rm_f)
        .exactly(derivative_paths.size).times
    end
  end

  describe '#create_derivatives' do
    before do
      allow(MiniMagick::Tool::Magick).to receive(:new).and_yield(magick_commands)
      allow(Hyrax::DerivativePath)
        .to receive(:derivative_path_for_reference)
        .and_return('/another/path/to/file-access.tif')
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
        '/path/to/file',
        '-define',
        'tiff:tile-geometry=128x128',
        '-compress',
        'jpeg',
        'ptif:/another/path/to/file-access.tif'
      ]
    end

    it 'sends imagemagick commands to MiniMagick' do
      service.create_derivatives('/path/to/file')

      expect(magick_commands).to eq(expected_commands)
    end
  end
end
