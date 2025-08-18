# frozen_string_literal: true
RSpec.describe Spot::Derivatives::IiifAccessCopyService, derivatives: true do
  subject(:service) { described_class.new(file_set) }

  let(:_file_set) { build(:file_set, width: [fs_width], height: [fs_height], mime_type: fs_mime_type) }
  let(:file_set) { _file_set }
  let(:valid_file_set) { _file_set }
  let(:fs_width) { '150' }
  let(:fs_height) { '150' }
  let(:fs_mime_type) { 'image/tif' }

  let(:mock_adapter) { instance_double(Valkyrie::Storage::Shrine, delete: true) }

  # AWS environment (maybe this should be a shared_context?)
  let(:aws_access_key_id) { 'AWS-access_key-id' }
  let(:aws_secret_access_key) { 'AWS-secret-access_key' }
  let(:aws_iiif_asset_bucket) { 'iiif-assets' }
  let(:mock_s3_client) { instance_double(Aws::S3::Client, delete_object: {}, put_object: {}) }
  let(:s3_derivative_key) { "#{file_set.id}-access.tif" }

  before do
    stub_env('AWS_ACCESS_KEY_ID', aws_access_key_id)
    stub_env('AWS_SECRET_ACCESS_KEY', aws_secret_access_key)
    stub_env('AWS_IIIF_ASSET_BUCKET', aws_iiif_asset_bucket)

    # allow(File).to receive(:exist?).with(derivative_path).and_return true
    # allow(File).to receive(:open).with(derivative_path, 'r')
    # allow(File).to receive(:directory?).with(File.dirname(derivative_path)).and_return(true)
    # allow(FileUtils).to receive(:rm_f).with(derivative_path)

    # allow(MiniMagick::Tool::Convert).to receive(:new).and_yield(magick_commands)
    # allow(FileUtils).to receive(:rm_f).with(File.dirname(derivative_path))
    # allow(File).to receive(:open).with(derivative_path, "r").and_return(stringio)
    # allow(Digest::MD5).to receive(:file).with(derivative_path).and_return(mock_digest)

    # allow(_file_set).to receive(:width).and_return(['150'])
    # allow(_file_set).to receive(:height).and_return(['150'])
    # allow(_file_set).to receive(:mime_type).and_return('image/tiff')
  end

  it_behaves_like 'a Hyrax::DerivativeService'

  describe '#cleanup_derivatives' do
    before do
      allow(Valkyrie::StorageAdapter)
        .to receive(:find)
        .with(:iiif_source_s3)
        .and_return(mock_adapter)

      service.cleanup_derivatives
    end

    it 'deletes the object from S3' do
      expect(mock_adapter)
        .to have_received(:delete)
        .with(id: s3_derivative_key)
    end
  end

  describe '#create_derivatives' do
    let(:magick_commands) do
      [].tap do |arr|
        arr.define_singleton_method(:merge!) do |args|
          args.each { |arg| self << arg }
        end
      end
    end

    let(:mock_io) { instance_double(IO) }
    let(:working_directory) { Rails.root.join('tmp', 'iiif-src') }
    let(:working_path) { working_directory.join("#{file_set.id}-access.tif") }

    before do
      allow(MiniMagick::Tool::Convert)
        .to receive(:new)
        .and_yield(magick_commands)

      allow(Hyrax::DerivativePath)
        .to receive(:derivative_path_for_reference)
        .with(file_set, 'access.tif')
        .and_return(s3_derivative_key)

      allow(mock_adapter).to receive(:upload)
      allow(File).to receive(:open).with(working_path).and_return(mock_io)

      service.create_derivatives(src_path)
    end

    let(:fs_width) { file_set.width.first }
    let(:fs_height) { file_set.height.first }

    describe 'sends `convert` command to MiniMagick' do
      subject { magick_commands }

      let(:expected_magick_commands) do
        ["#{src_path}[0]", '-define', 'tiff:tile-geometry=128x128', '-compress', 'jpeg', "ptif:#{derivative_path}"]
      end

      it { is_expected.to eq expected_magick_commands }
    end

    describe 'uploads the object to S3 with Valkyrie-Shrine adapter' do
      it do
        expect(mock_adapter)
          .to have_received(:upload)
          .with(
            resource: file_set,
            file: mock_io,
            original_filename: s3_derivative_key,
            metadata: {
              'width' => fs_width,
              'height' => fs_height
            }
          )
      end
    end

    describe 'cleans up the shuttle derivative' do
      before do
        allow(File).to receive(:exist?).with(working_path).and_return(true)
      end
    end

    it 'rimrafs the derivative_path provided' do
      expect(FileUtils).to have_received(:rm_f).with(derivative_path)
    end
  end

  describe '#valid?' do
    subject { described_class.new(file_set).valid? }

    context 'when no S3 bucket name set in environment' do
      let(:aws_iiif_asset_bucket) { nil }

      before do
        allow(Rails.logger).to receive(:warn)
      end

      it 'logs a warning and returns false' do
        expect(described_class.new(file_set).valid?).to be false
        expect(Rails.logger).to have_received(:warn).with(/AWS_IIIF_ASSET_BUCKET environment variable is not defined/)
      end
    end

    context 'when the work is an image' do

    end
  end
end
