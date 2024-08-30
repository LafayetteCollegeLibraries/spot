# frozen_string_literal: true
RSpec.describe Spot::Derivatives::VideoDerivativeService, derivatives: true do
  let(:service) { described_class.new(file_set) }

  let(:_file_set) { build(:file_set) }
  let(:file_set) { _file_set }
  let(:valid_file_set) { _file_set }
  let(:fs_mime_type) { 'video/mp4' }

  let(:mock_file) { Hydra::PCDM::File.new }
  let(:derivative_path) { '/rails/tmp/derivatives/ab/c1/23/de/f-access.mp4' }
  let(:derivative_path_high) { '/rails/tmp/derivatives/ab/c1/23/de/f-access-high.mp4' }
  let(:derivative_path_low) { '/rails/tmp/derivatives/ab/c1/23/de/f-access-low.mp4' }
  let(:src_path) { '/original/path/to/src/file.mp4' }
  let(:file_size) { 0 }
  let(:file_digest) { 'base64digest' }
  let(:stringio) { StringIO.new('hi') }
  let(:mock_digest) { instance_double(Digest::MD5, base64digest: file_digest) }

  # AWS environment (maybe this should be a shared_context?)
  let(:aws_access_key_id) { 'AWS-access_key-id' }
  let(:aws_secret_access_key) { 'AWS-secret-access_key' }
  let(:aws_av_asset_bucket) { 'av-assets' }
  let(:aws_import_bucket) { 'ldr-imports' }
  let(:mock_s3_client) { instance_double(Aws::S3::Client) }
  let(:s3_key) { "#{file_set.id}-0-access-480.mp4" }

  before do
    stub_env('AWS_ACCESS_KEY_ID', aws_access_key_id)
    stub_env('AWS_SECRET_ACCESS_KEY', aws_secret_access_key)
    stub_env('AWS_AV_ASSET_BUCKET', aws_av_asset_bucket)
    stub_env('AWS_BULKRAX_IMPORTS_BUCKET', aws_import_bucket)

    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'access-high.mp4')
      .and_return("#{derivative_path_high}.access-high.mp4")

    allow(Hyrax::DerivativePath)
      .to receive(:derivative_path_for_reference)
      .with(file_set, 'access-low.mp4')
      .and_return("#{derivative_path_low}.access-low.mp4")

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
    subject { service.cleanup_derivatives }

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

  describe '#derivative_urls' do
    subject { service.derivative_urls }

    it { is_expected.to eq ["file://#{derivative_path_high}", "file://#{derivative_path_low}"] }
  end

  describe '#valid?' do
    subject { service.valid? }

    context 'when no S3 bucket name set in environment' do
      let(:aws_av_asset_bucket) { nil }

      before do
        allow(Rails.logger).to receive(:warn)
      end

      it 'logs a warning and returns false' do
        expect(service.valid?).to be false
        expect(Rails.logger).to have_received(:warn)
          .with('Skipping audio derivative generation because the AWS_AUDIO_VISUAL_BUCKET environment variable is not defined.')
      end
    end

    context 'when the fileset has the wrong mime type' do
      before do
        allow(_file_set).to receive(:mime_type).and_return('image/tiff')
      end

      it 'returns false' do
        expect(service.valid?).to be false
      end
    end

    context 'when the fileset has the correct mime type' do
      before do
        allow(_file_set).to receive(:mime_type).and_return('video/mp4')
      end

      it 'returns true' do
        expect(service.valid?).to be true
      end
    end
  end

  describe '#upload_derivatives_to_s3' do
    subject { service.upload_derivatives_to_s3(keys, paths) }

    let(:key) { '1234_0_access_480.mp4' }
    let(:keys) { [key] }
    let(:paths) { [derivative_path] }
    let(:mock_parent) { instance_double(AudioVisual) }

    before do
      allow(file_set).to receive(:parent).and_return(mock_parent)
    end

    context 'when stored_derivatives is empty' do
      let(:stored) { [] }

      before do
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(mock_parent).to receive(:stored_derivatives=).with(["1234_0_access_480.mp4"])
        allow(mock_parent).to receive(:save)
        allow(mock_s3_client)
          .to receive(:put_object)
          .with(bucket: aws_av_asset_bucket, key: key, body: stringio, content_length: file_size, content_md5: file_digest, metadata: {})
        service.send(:upload_derivatives_to_s3, keys, paths)
      end

      it 'saves the key to stored derivatives and uploads to s3' do
        expect(mock_s3_client)
          .to have_received(:put_object)
          .with(bucket: aws_av_asset_bucket, key: key, body: stringio, content_length: file_size, content_md5: file_digest, metadata: {})
        expect(mock_parent).to have_received(:stored_derivatives=).with(["1234_0_access_480.mp4"])
        expect(mock_parent).to have_received(:save)
      end
    end

    context 'when stored_derivatives is not empty' do
      let(:stored) { ["5678_0_access_480.mp4"] }

      before do
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(mock_parent).to receive(:stored_derivatives=).with(["5678_0_access_480.mp4", "1234_0_access_480.mp4"])
        allow(mock_parent).to receive(:save)
        allow(mock_s3_client)
          .to receive(:put_object)
          .with(bucket: aws_av_asset_bucket, key: key, body: stringio, content_length: file_size, content_md5: file_digest, metadata: {})
        service.send(:upload_derivatives_to_s3, keys, paths)
      end

      it 'saves the key to stored derivatives and uploads to s3' do
        expect(mock_s3_client)
          .to have_received(:put_object)
          .with(bucket: aws_av_asset_bucket, key: key, body: stringio, content_length: file_size, content_md5: file_digest, metadata: {})
        expect(mock_parent).to have_received(:stored_derivatives=).with(["5678_0_access_480.mp4", "1234_0_access_480.mp4"])
        expect(mock_parent).to have_received(:save)
      end
    end
  end

  describe '#transfer_s3_derivative' do
    subject { service.transfer_s3_derivative(derivative, key) }

    let(:key) { '1234_0_access_480.mp4' }
    let(:derivative) { 'derivative_480.mp4' }
    let(:mock_parent) { instance_double(AudioVisual) }
    let(:source_path) { "/" + aws_import_bucket + "/" + derivative }

    before do
      allow(file_set).to receive(:parent).and_return(mock_parent)
    end

    context 'when stored_derivatives is empty' do
      let(:stored) { [] }

      before do
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(mock_parent).to receive(:stored_derivatives=).with(["1234_0_access_480.mp4"])
        allow(mock_parent).to receive(:save)
        allow(mock_s3_client)
          .to receive(:copy_object)
          .with(bucket: aws_av_asset_bucket, copy_source: source_path, key: key)
        service.send(:transfer_s3_derivative, derivative, key)
      end

      it 'saves the key to stored derivatives and uploads to s3' do
        expect(mock_parent).to have_received(:stored_derivatives=).with(["1234_0_access_480.mp4"])
        expect(mock_parent).to have_received(:save)
        expect(mock_s3_client)
          .to have_received(:copy_object)
          .with(bucket: aws_av_asset_bucket, copy_source: source_path, key: key)
      end
    end

    context 'when stored_derivatives is not empty' do
      let(:stored) { ["5678_0_access_480.mp4"] }

      before do
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(mock_parent).to receive(:stored_derivatives=).with(["5678_0_access_480.mp4", "1234_0_access_480.mp4"])
        allow(mock_parent).to receive(:save)
        allow(mock_s3_client)
          .to receive(:copy_object)
          .with(bucket: aws_av_asset_bucket, copy_source: source_path, key: key)
        service.send(:transfer_s3_derivative, derivative, key)
      end

      it 'saves the key to stored derivatives and uploads to s3' do
        expect(mock_parent).to have_received(:stored_derivatives=).with(["5678_0_access_480.mp4", "1234_0_access_480.mp4"])
        expect(mock_parent).to have_received(:save)
        expect(mock_s3_client)
          .to have_received(:copy_object)
          .with(bucket: aws_av_asset_bucket, copy_source: source_path, key: key)
      end
    end
  end

  describe '#derivative_paths' do
    subject { service.derivative_paths }

    it { is_expected.to eq([derivative_path_high, derivative_path_low]) }
  end

  describe '#get_video_resolution' do
    subject { service.get_video_resolution(filename) }

    let(:filename) { src_path }
    let(:mock_ffprobe) { instance_double(Ffprober::Wrapper, video_streams: [stream]) }
    let(:stream) { double(width: 100, height: 200) }

    before do
      allow(Ffprober::Parser).to receive(:from_file).with(filename).and_return(mock_ffprobe)
    end

    it 'returns the resolution as an array of width and height' do
      is_expected.to eq([100, 200])
    end
  end

  describe '#get_derivative_resolution' do
    subject { service.get_derivative_resolution(filename, height) }

    let(:filename) { src_path }
    let(:height) { 480 }

    context "width is mod 16" do
      before do
        allow(service).to receive(:get_video_resolution).with(filename).and_return([100, 200])
      end

      it { is_expected.to eq("240x480") }
    end

    context "width is not mod 16" do
      before do
        allow(service).to receive(:get_video_resolution).with(filename).and_return([110, 200])
      end

      it { is_expected.to eq("272x480") }
    end
  end

  describe '#check_premade_derivatives' do
    subject { service.check_premade_derivatives }

    let(:mock_parent) { instance_double(AudioVisual) }

    before do
      allow(file_set).to receive(:parent).and_return(mock_parent)
    end

    context 'stored_derivatives full, premade_derivatives empty' do
      let(:stored) { ['derivative_1', 'derivative_2'] }
      let(:premade) { [] }

      before do
        allow(mock_parent).to receive(:premade_derivatives).and_return(premade)
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(service).to receive(:rename_premade_derivative).with('derivative_1', 0)
        allow(service).to receive(:rename_premade_derivative).with('derivative_2', 1)
        service.check_premade_derivatives
      end

      it 'should not call rename' do
        expect(service).to_not receive(:rename_premade_derivative).with('derivative_1', 0)
        expect(service).to_not receive(:rename_premade_derivative).with('derivative_2', 1)
      end

      it { is_expected.to eq(true) }
    end

    context 'stored_derivatives full, premade_derivatives full' do
      let(:stored) { ['derivative_1', 'derivative_2'] }
      let(:premade) { ['derivative_1', 'derivative_2'] }

      before do
        allow(mock_parent).to receive(:premade_derivatives).and_return(premade)
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(service).to receive(:rename_premade_derivative).with('derivative_1', 0)
        allow(service).to receive(:rename_premade_derivative).with('derivative_2', 1)
        service.check_premade_derivatives
      end

      it 'should not call rename' do
        expect(service).to_not receive(:rename_premade_derivative).with('derivative_1', 0)
        expect(service).to_not receive(:rename_premade_derivative).with('derivative_2', 1)
      end

      it { is_expected.to eq(true) }
    end

    context 'stored_derivatives empty, premade_derivatives empty' do
      let(:stored) { [] }
      let(:premade) { [] }

      before do
        allow(mock_parent).to receive(:premade_derivatives).and_return(premade)
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(service).to receive(:rename_premade_derivative).with('derivative_1', 0)
        allow(service).to receive(:rename_premade_derivative).with('derivative_2', 1)
        service.check_premade_derivatives
      end

      it 'should not call rename' do
        expect(service).to_not receive(:rename_premade_derivative).with('derivative_1', 0)
        expect(service).to_not receive(:rename_premade_derivative).with('derivative_2', 1)
      end

      it { is_expected.to eq(false) }
    end

    context 'stored_derivatives empty, premade_derivatives full' do
      let(:stored) { [] }
      let(:premade) { ['derivative_1', 'derivative_2'] }

      before do
        allow(mock_parent).to receive(:premade_derivatives).and_return(premade)
        allow(mock_parent).to receive(:stored_derivatives).and_return(stored)
        allow(service).to receive(:rename_premade_derivative).with('derivative_1', 0)
        allow(service).to receive(:rename_premade_derivative).with('derivative_2', 1)
        service.check_premade_derivatives
      end

      it 'should call rename' do
        expect(service).to have_received(:rename_premade_derivative).with('derivative_1', 0)
        expect(service).to have_received(:rename_premade_derivative).with('derivative_2', 1)
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#rename_premade_derivative' do
    subject { service.rename_premade_derivative(derivative, index) }

    let(:derivative) { 'derivative_1' }
    let(:index) { 0 }

    before do
      allow(_file_set).to receive(:id).and_return("1234")
      allow(File).to receive(:exist?).with('/tmp/derivative_1').and_return true
      allow(FileUtils).to receive(:rm_f).with('/tmp/derivative_1')
      allow(mock_s3_client).to receive(:get_object).with(key: derivative, bucket: aws_import_bucket, response_target: '/tmp/derivative_1')
      allow(service).to receive(:get_video_resolution).with('/tmp/derivative_1').and_return [100, 200]
      allow(service).to receive(:transfer_s3_derivative).with('derivative_1', '1234-0-access-200.mp4')
      service.rename_premade_derivative(derivative, index)
    end

    it 'should call to transfer the premade derivative' do
      expect(service).to have_received(:transfer_s3_derivative).with('derivative_1', '1234-0-access-200.mp4')
    end
  end

  describe '#create_derivatives' do
    subject { service.create_derivatives(filename) }

    let(:filename) { mock_file }

    context 'check_premade_derivatives returns true' do
      before do
        allow(service).to receive(:check_premade_derivatives).and_return(true)
        service.create_derivatives(filename)
      end

      it 'should return immediately' do
        expect(service).to_not receive(:create_derivative_files)
      end
    end

    context 'check_premade_derivatives returns true' do
      before do
        allow(service).to receive(:check_premade_derivatives).and_return(false)
        allow(service).to receive(:get_derivative_resolution).with(filename, 1080).and_return('544x1080')
        allow(service).to receive(:get_derivative_resolution).with(filename, 480).and_return('240x480')
        allow(Hydra::Derivatives::VideoDerivatives)
          .to receive(:create)
          .with(filename, outputs: [
            { label: 'high',
              format: 'mp4',
              url: "file://#{derivative_path_high}",
              size: '544x1080',
              input_options: "-t 10 -ss 1",
              video: "-g 30 -b:v 8000k",
              audio: "-b:a 256k -ar 44100" },
            { label: 'low',
              format: 'mp4',
              url: "file://#{derivative_path_low}",
              size: '240x480',
              input_options: "-t 10 -ss 1",
              video: "-g 30 -b:v 2500k",
              audio: "-b:a 256k -ar 44100" }
            ])
        allow(_file_set).to receive(:id).and_return("1234")
        allow(service).to receive(:upload_derivatives_to_s3).with(['1234-0-access-1080.mp4', '1234-1-access-480.mp4'], [derivative_path_high, derivative_path_low])
        allow(File).to receive(:exist?).with(derivative_path_high).and_return true
        allow(FileUtils).to receive(:rm_f).with(derivative_path_high)
        allow(File).to receive(:exist?).with(derivative_path_low).and_return true
        allow(FileUtils).to receive(:rm_f).with(derivative_path_low)
        service.create_derivatives(filename)
      end

      it 'creates derivative files' do
        expect(Hydra::Derivatives::VideoDerivatives)
          .to have_received(:create)
          .with(filename, outputs: [
            { label: 'high',
              format: 'mp4',
              url: "file://#{derivative_path_high}",
              size: '544x1080',
              input_options: "-t 10 -ss 1",
              video: "-g 30 -b:v 8000k",
              audio: "-b:a 256k -ar 44100" },
            { label: 'low',
              format: 'mp4',
              url: "file://#{derivative_path_low}",
              size: '240x480',
              input_options: "-t 10 -ss 1",
              video: "-g 30 -b:v 2500k",
              audio: "-b:a 256k -ar 44100" }
            ])
      end

      it 'uploads derivatives to s3' do
        expect(service).to have_received(:upload_derivatives_to_s3).with(['1234-0-access-1080.mp4', '1234-1-access-480.mp4'], [derivative_path_high, derivative_path_low])
      end

      it 'removes temporary files' do
        expect(FileUtils).to have_received(:rm_f).with(derivative_path_high)
        expect(FileUtils).to have_received(:rm_f).with(derivative_path_low)
      end
    end
  end
end
