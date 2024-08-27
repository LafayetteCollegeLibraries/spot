# frozen_string_literal: true
RSpec.describe Spot::Derivatives::AudioVisualBaseDerivativeService, derivatives: true do
  let(:service) { described_class.new(file_set) }

  let(:_file_set) { build(:file_set) }
  let(:file_set) { _file_set }
  let(:valid_file_set) { _file_set }
  let(:fs_mime_type) { 'video/mp4' }

  let(:mock_file) { Hydra::PCDM::File.new }
  let(:derivative_path) { '/rails/tmp/derivatives/ab/c1/23/de/f-access.mp4' }
  let(:src_path) { '/original/path/to/src/file.mp4' }
  let(:file_size) { 0 }
  let(:file_digest) { 'base64digest' }
  let(:stringio) { StringIO.new('hi') }
  let(:mock_digest) { instance_double(Digest::MD5, base64digest: file_digest) }

  # AWS environment (maybe this should be a shared_context?)
  let(:aws_access_key_id) { 'AWS-access_key-id' }
  let(:aws_secret_access_key) { 'AWS-secret-access_key' }
  let(:aws_av_asset_bucket) { 'av-assets' }
  let(:mock_s3_client) { instance_double(Aws::S3::Client) }
  let(:s3_key) { "#{file_set.id}-0-access-480.mp4" }

  before do
    stub_env('AWS_ACCESS_KEY_ID', aws_access_key_id)
    stub_env('AWS_SECRET_ACCESS_KEY', aws_secret_access_key)
    stub_env('AWS_AV_ASSET_BUCKET', aws_av_asset_bucket)

    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'access.mp4')
      .and_return("#{derivative_path}.access.mp4")

    allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)

    allow(File).to receive(:exist?).with(derivative_path).and_return true
    allow(File).to receive(:open).with(derivative_path, 'r')
    allow(File).to receive(:size).with(derivative_path).and_return(file_size)
    allow(File).to receive(:directory?).with(File.dirname(derivative_path)).and_return(true)
    allow(FileUtils).to receive(:rm_f).with(derivative_path)

    allow(FileUtils).to receive(:rm_f).with(File.dirname(derivative_path))
    allow(File).to receive(:open).with(derivative_path, "r").and_return(stringio)
    allow(Digest::MD5).to receive(:file).with(derivative_path).and_return(mock_digest)

    allow(_file_set).to receive(:mime_type).and_return('video/mp4')
  end

  it_behaves_like 'a Hyrax::DerivativeService'

  describe '#cleanup_derivatives' do
    subject { described_class.new(file_set).cleanup_derivatives }

    let(:response) { { contents: [{ key: '1234-0-access-480.mp4' }, { key: '1234-0-access-1080.mp4' }, { key: '5678-0-access-480.mp4' }, { key: '5678-0-access-1080.mp4' }] } }
    let(:delete) { { objects: [{ key: '1234-0-access-480.mp4' }, { key: '1234-0-access-1080.mp4' }], quiet: false } }

    before do
      allow(mock_s3_client).to receive(:list_objects).with(bucket: aws_av_asset_bucket).and_return response
      allow(_file_set).to receive(:id).and_return("1234")
      allow(mock_s3_client).to receive(:delete_objects).with(bucket: aws_av_asset_bucket, delete: delete)
      service.cleanup_derivatives
    end

    it 'deletes objects from S3' do
      expect(mock_s3_client)
        .to have_received(:delete_objects)
        .with(bucket: aws_av_asset_bucket, delete: delete)
    end
  end

  describe '#valid?' do
    subject { described_class.new(file_set).valid? }

    context 'when no S3 bucket name set in environment' do
      let(:aws_av_asset_bucket) { nil }

      before do
        allow(Rails.logger).to receive(:warn)
      end

      it 'logs a warning and returns false' do
        expect(described_class.new(file_set).valid?).to be false
        expect(Rails.logger).to have_received(:warn)
          .with('Skipping audio derivative generation because the AWS_AUDIO_VISUAL_BUCKET environment variable is not defined.')
      end
    end

    context 'when the fileset has the wrong mime type' do
      before do
        allow(_file_set).to receive(:mime_type).and_return('image/tiff')
      end

      it 'returns false' do
        expect(described_class.new(file_set).valid?).to be false
      end
    end

    context 'when the fileset has the correct mime type' do
      before do
        allow(_file_set).to receive(:mime_type).and_return('video/mp4')
      end

      it 'returns true' do
        expect(described_class.new(file_set).valid?).to be true
      end
    end
  end
end
