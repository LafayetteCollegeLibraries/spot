# frozen_string_literal: true
RSpec.describe Spot::Derivatives::AccessMasterService do
  subject(:service) { described_class.new(file_set) }

  let(:file_set) { build(:file_set, id: 'abc123def') }
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

  let(:expected_magick_commands) do
    ["#{src_path}[0]", '-define', 'tiff:tile-geometry=128x128', '-compress', 'jpeg', "ptif:#{derivative_path}"]
  end

  # rubocop:disable RSpec/InstanceVariable
  before do
    @aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
    @aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    @aws_iiif_asset_bucket = ENV['AWS_IIIF_ASSET_BUCKET']
    %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACESS_KEY AWS_IIIF_ASSET_BUCKET].each { |k| ENV.delete(k) }

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

    allow(file_set).to receive(:width).and_return(['150'])
    allow(file_set).to receive(:height).and_return(['150'])
  end

  after do
    ENV['AWS_ACCESS_KEY_ID'] = @aws_access_key_id unless @aws_access_key_id.blank?
    ENV['AWS_SECRET_ACCESS_KEY'] = @aws_secret_access_key unless @aws_secret_access_key.blank?
    ENV['AWS_IIIF_ASSET_BUCKET'] = @aws_iiif_asset_bucket unless @aws_iiif_asset_bucket.blank?
  end
  # rubocop:enable RSpec/InstanceVariable

  describe '#cleanup_derivatives' do
    it 'rimrafs the derivative_path provided' do
      service.cleanup_derivatives

      expect(FileUtils).to have_received(:rm_f).with(derivative_path)
    end
  end

  describe '#create_derivatives' do
    it 'sends `convert` commands to MiniMagick' do
      service.create_derivatives(src_path)

      expect(magick_commands).to eq(expected_magick_commands)
    end
  end

  context 'when AWS environment variables are available' do
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
    end

    describe '#cleanup_derivatives' do
      subject { service.cleanup_derivatives }

      it 'deletes the object from S3' do
        service.cleanup_derivatives

        expect(mock_s3_client)
          .to have_received(:delete_object)
          .with(bucket: aws_iiif_asset_bucket, key: s3_key)
      end
    end

    describe '#create_derivatives' do
      let(:fs_width) { file_set.width.first }
      let(:fs_height) { file_set.height.first }

      it 'puts the object into S3' do
        service.create_derivatives(derivative_path)

        expect(mock_s3_client)
          .to have_received(:put_object)
          .with(
            bucket: aws_iiif_asset_bucket,
            key: s3_key,
            body: stringio,
            content_md5: file_digest,
            content_length: file_size,
            metadata: {
              width: fs_width,
              height: fs_height
            }
          )

        expect(FileUtils).to have_received(:rm_f).with(derivative_path)
      end
    end
  end
end
