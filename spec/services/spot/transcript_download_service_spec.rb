# frozen_string_literal: true
RSpec.describe Spot::TranscriptDownloadService do
  let(:service) { described_class.new(file_set: file_set, transcript_name: transcript_name) }
  let(:_file_set) { build(:file_set) }
  let(:file_set) { _file_set }
  let(:transcript_name) { "transcript.vtt" }

  # AWS environment (maybe this should be a shared_context?)
  let(:aws_import_bucket) { 'ldr-imports' }
  let(:aws_access_key_id) { 'AWS-access_key-id' }
  let(:aws_secret_access_key) { 'AWS-secret-access_key' }
  let(:mock_s3_client) { instance_double(Aws::S3::Client) }

  before do
    stub_env('AWS_ACCESS_KEY_ID', aws_access_key_id)
    stub_env('AWS_SECRET_ACCESS_KEY', aws_secret_access_key)
    stub_env('AWS_BULKRAX_IMPORTS_BUCKET', aws_import_bucket)

    allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
  end

  describe '#download_transcript' do
    let(:path) { '/__w/spot/spot/tmp/premade_derivatives/' + transcript_name }

    before do
      allow(mock_s3_client).to receive(:get_object).with(key: transcript_name, bucket: aws_import_bucket, response_target: path)
      allow(Spot::FileSetTranscriptAttachmentService).to receive(:attach).with(path: path, file_set: file_set)
    end

    it 'pulls the file and calls the attachment service' do
      service.download_transcript

      expect(mock_s3_client).to have_received(:get_object).with(key: transcript_name, bucket: aws_import_bucket, response_target: path)
      expect(Spot::FileSetTranscriptAttachmentService).to have_received(:attach).with(path: path, file_set: file_set)
    end
  end
end
