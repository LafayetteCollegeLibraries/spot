# frozen_string_literal: true
RSpec.describe Spot::Derivatives::ThumbnailService do
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
      allow(Hydra::Derivatives::ImageDerivatives).to receive(:create)
    end

    let(:filename) { '/path/to/a/source/file.tif' }

    let(:expected_outputs) do
      [
        {
          label: :thumbnail,
          format: 'jpg',
          size: '200x150>',
          url: 'file:/path/to/a/fs-thumbnail.jpg',
          layer: 0
        }
      ]
    end

    it 'calls Hydra::Derivatives::ImageDerivatives with outputs' do
      service.create_derivatives(filename)

      expect(Hydra::Derivatives::ImageDerivatives)
        .to have_received(:create)
        .with(filename, outputs: expected_outputs)
    end
  end
end
