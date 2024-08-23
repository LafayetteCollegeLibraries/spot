# frozen_string_literal: true
RSpec.describe AudioVisualHelper do
  describe '#s3_url' do
    subject { helper.s3_url(key) }

    let(:key) { '1234-0-access.mp3' }
    let(:s3_bucket) { 'av-derivatives' }
    let(:client_opts) { {} }
    let(:mock_s3_client) { instance_double(Aws::S3::Client) }
    let(:mock_s3_object) { instance_double(Aws::S3::Object) }
    let(:url) { "s3://#{s3_bucket}/#{key}" }

    stub_env('AWS_AV_ASSET_BUCKET', 'av-derivatives')

    before do
      allow(Aws::S3::Client).to receive(:new).with(client_opts).and_return(mock_s3_client)
      allow(Aws::S3::Object).to receive(:new).with(bucket_name: s3_bucket, key: key, client: mock_s3_client).and_return(mock_s3_object)
      allow(mock_s3_object).to receive(:presigned_url).with(:get, expires_in: 3600).and_return(url)
    end

    it { is_expected.to eq url }
  end
end
