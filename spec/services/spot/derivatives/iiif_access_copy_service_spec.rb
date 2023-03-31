# frozen_string_literal: true
RSpec.describe Spot::Derivatives::IiifAccessCopyService, derivatives: true do
  subject(:service) { described_class.new(file_set) }

  let(:_file_set) { build(:file_set) }
  let(:file_set) { _file_set }
  let(:valid_file_set) { _file_set }

  let(:mock_file) { Hydra::PCDM::File.new }
  let(:derivative_path) { '/rails/tmp/derivatives/ab/c1/23/de/f-access.tif' }
  let(:src_path) { '/original/path/to/src/file.tif' }
  let(:file_size) { 0 }
  let(:file_digest) { 'base64digest' }
  let(:stringio) { StringIO.new('hi') }
  let(:mock_digest) { instance_double(Digest::MD5, base64digest: file_digest) }

  let(:magick_commands) do
    [].tap do |arr|
      arr.define_singleton_method(:merge!) do |args|
        args.each { |arg| self << arg }
      end
    end
  end

  # AWS environment (maybe this should be a shared_context?)
  let(:aws_access_key_id) { 'AWS-access_key-id' }
  let(:aws_secret_access_key) { 'AWS-secret-access_key' }
  let(:aws_iiif_asset_bucket) { 'iiif-assets' }
  let(:mock_s3_client) { instance_double(Aws::S3::Client, delete_object: {}, put_object: {}) }
  let(:s3_key) { "#{file_set.id}-access.tif" }

  before do
    stub_env('AWS_ACCESS_KEY_ID', aws_access_key_id)
    stub_env('AWS_SECRET_ACCESS_KEY', aws_secret_access_key)
    stub_env('AWS_IIIF_ASSET_BUCKET', aws_iiif_asset_bucket)

    allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)

    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'access.tif')
      .and_return("#{derivative_path}.access.tif")

    allow(File).to receive(:exist?).with(derivative_path).and_return true
    allow(File).to receive(:open).with(derivative_path, 'r')
    allow(File).to receive(:size).with(derivative_path).and_return(file_size)
    allow(File).to receive(:directory?).with(File.dirname(derivative_path)).and_return(true)
    allow(FileUtils).to receive(:rm_f).with(derivative_path)

    allow(MiniMagick::Tool::Convert).to receive(:new).and_yield(magick_commands)
    allow(FileUtils).to receive(:rm_f).with(File.dirname(derivative_path))
    allow(File).to receive(:open).with(derivative_path, "r").and_return(stringio)
    allow(Digest::MD5).to receive(:file).with(derivative_path).and_return(mock_digest)

    allow(_file_set).to receive(:width).and_return(['150'])
    allow(_file_set).to receive(:height).and_return(['150'])
    allow(_file_set).to receive(:mime_type).and_return('image/tiff')
  end

  it_behaves_like 'a Hyrax::DerivativeService'

  describe '#cleanup_derivatives' do
    before { service.cleanup_derivatives }

    it 'deletes the object from S3' do
      expect(mock_s3_client)
        .to have_received(:delete_object)
        .with(bucket: aws_iiif_asset_bucket, key: s3_key)
    end
  end

  describe '#create_derivatives' do
    before { service.create_derivatives(src_path) }

    let(:fs_width) { file_set.width.first }
    let(:fs_height) { file_set.height.first }
    let(:expected_magick_commands) do
      ["#{src_path}[0]", '-define', 'tiff:tile-geometry=128x128', '-compress', 'jpeg', "ptif:#{derivative_path}"]
    end

    it 'sends `convert` commands to MiniMagick' do
      expect(magick_commands).to eq(expected_magick_commands)
    end

    it 'rimrafs the derivative_path provided' do
      expect(FileUtils).to have_received(:rm_f).with(derivative_path)
    end

    it 'puts the object into S3' do
      expect(mock_s3_client)
        .to have_received(:put_object)
        .with(
          bucket: aws_iiif_asset_bucket,
          key: s3_key,
          body: stringio,
          content_md5: file_digest,
          content_length: file_size,
          metadata: {
            'width' => fs_width,
            'height' => fs_height
          }
        )
    end
  end
end
