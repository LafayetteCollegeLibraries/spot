# frozen_string_literal: true
RSpec.describe Spot::Derivatives::AccessMasterService do
  subject(:service) { described_class.new(file_set) }

  let(:file_set) { build(:file_set, id: 'abc123def') }
  let(:derivative_path) { '/path/to/a/fs-access.tif' }
  let(:src_path) { '/another/path/to/src/file.tif' }
  let(:magick_commands) do
    [].tap do |arr|
      arr.define_singleton_method(:merge!) do |args|
        args.each { |arg| self << arg }
      end
    end
  end

  before do
    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'access.tif')
      .and_return("#{derivative_path}.access.tif")

    allow(File).to receive(:exist?).with(derivative_path).and_return true
    allow(FileUtils).to receive(:rm_f).with(derivative_path)

    allow(MiniMagick::Tool::Convert).to receive(:new).and_yield(magick_commands)
    allow(FileUtils).to receive(:mkdir_p).with(File.dirname(derivative_path))
  end

  shared_examples 'it rimrafs the derivative_path provided' do
    it do
      cleanup_derivatives!
      expect(FileUtils).to have_received(:rm_f).with(derivative_path)
    end
  end

  shared_examples 'it sends commands to MiniMagick' do
    it do
      create_derivatives!

      expect(magick_commands)
        .to eq([
          "#{src_path}[0]",
          '-define', 'tiff:tile-geometry=128x128',
          '-compress', 'jpeg',
          "ptif:#{derivative_path}"
        ])
    end
  end

  describe '#cleanup_derivatives' do
    it_behaves_like 'it rimrafs the derivative_path provided'
  end

  describe '#create_derivatives' do
    it_behaves_like 'it sends commands to MiniMagick'
  end

  context 'when AWS environment variables are available' do
    let(:aws_access_key_id) { 'AWS-access_key-id' }
    let(:aws_secret_access_key) { 'AWS-secret-access_key' }
    let(:aws_iiif_asset_bucket) { 'iiif-assets' }
    let(:mock_s3_client) { Aws::S3::Client.new(stub_responses: true) }
    let(:s3_key) { "#{file_set.id}-access.tif" }
    let(:file_size) { 0 }
    let(:file_digest) { '<MD5 hash>' }
    let(:stringio) { StringIO.new('hi') }

    before do
      stub_env('AWS_ACCESS_KEY_ID', aws_access_key_id)
      stub_env('AWS_SECRET_ACCESS_KEY', aws_secret_access_key)
      stub_env('AWS_IIIF_ASSET_BUCKET', aws_iiif_asset_bucket)

      allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
      allow(File).to receive(:size).with(src_path).and_return(file_size)
      allow(File).to receive(:open).with(src_path).and_return(stringio)
      allow(Digest::MD5).to receive(:file).with(src_path).and_return(file_digest)
    end

    describe '#cleanup_derivatives' do
      subject(:cleanup_derivatives!) { service.cleanup_derivatives }

      before do
        mock_s3_client.stub_data(:delete_object, {})
      end

      it_behaves_like 'it rimrafs the derivative_path provided'

      it 'deletes the object from S3' do
        expect(mock_s3_client)
          .to have_received(:destroy_object)
          .with(bucket: aws_iiif_asset_bucket, key: s3_key)
      end
    end

    describe '#create_derivatives' do
      subject(:create_derivatives!) { service.create_derivatives(src_path) }

      before do
        mock_s3_client.stub_data(:put_object, {})
      end

      it_behaves_like 'it sends commands to MiniMagick'

      it 'puts the object into S3' do
        create_derivatives!

        expect(mock_s3_client)
          .to have_received(:put_object)
          .with(
            bucket: aws_iiif_asset_bucket,
            key: s3_key,
            body: stringio,
            content_md5: file_digest,
            content_length: file.length,
          )
      end
    end
  end
end
