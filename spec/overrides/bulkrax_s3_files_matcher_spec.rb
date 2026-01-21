# frozen_string_literal: true
# Tests to make sure that browse everything can read s3 urls
# Test format is copied from original Browse Everything tests
#
RSpec.describe Spot::BulkraxS3FilesMatcher do
  subject(:matcher) { described_class.new }

  describe '#parse_remote_files' do
    subject {matcher.parse_remote_files(src)}

    context 'src is empty' do
      let(:src) { '' }

      it 'returns the correct size' do
        expect(retriever.send(:get_file_size, options)).to eq file_size
      end
    end

    context 'src is not empty' do
      let(:src) { 'project/file.jpg' }
      let(:key) { src }
      let(:s3_bucket) { 'ldr-imports' }
      let(:mock_s3_client) { instance_double(Aws::S3::Client) }
      let(:mock_s3_object) { instance_double(Aws::S3::Object) }
      let(:url) { "s3://#{s3_bucket}/#{key}" }

      before do
        stub_env('AWS_AV_ASSET_BUCKET', s3_bucket)
        allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
        allow(Aws::S3::Object).to receive(:new).with(bucket_name: s3_bucket, key: src, client: mock_s3_client).and_return(mock_s3_object)
        allow(mock_s3_object).to receive(:presigned_url).with(:get, expires_in: 3600).and_return(url)
      end

      context 'the object does not exist' do
        before do
          allow(mock_s3_client).to receive(:head_object).with(bucket: s3_bucket, key: key).and_raise(Aws::S3::Errors::NotFound.new(nil, nil))
          allow(Rails.logger).to receive(:warn).with('S3: Key not found.')
        end

        it 'logs a warning and returns the empty string' do
          expect(matcher.parse_remote_files(src)).to eq "S3: Key not found."
          expect(Rails.logger).to have_received(:warn)
            .with('S3: Key not found.')
        end
      end

      context 'the object exists' do
        let(:mock_s3_head) { instance_double(Aws::S3::Types::HeadObjectOutput) }
        let(:name) { 'file.jpg' }

        before do
          allow(mock_s3_client).to receive(:head_object).with(key: key, bucket: 'av-derivatives').and_return(mock_s3_head)
        end

        it 'returns the name and url' do
          expect(matcher.parse_remote_files(src)).to eq { url: url, file_name: name }
        end
      end
    end
  end
end
