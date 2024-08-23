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

    before do
      stub_env('AWS_AV_ASSET_BUCKET', 'av-derivatives')
      allow(Aws::S3::Client).to receive(:new).with(client_opts).and_return(mock_s3_client)
      allow(Aws::S3::Object).to receive(:new).with(bucket_name: s3_bucket, key: key, client: mock_s3_client).and_return(mock_s3_object)
      allow(mock_s3_object).to receive(:presigned_url).with(:get, expires_in: 3600).and_return(url)
    end

    it { is_expected.to eq url }
  end

  describe '#get_original_name' do
    subject { get_original_name(presenters, derivative) }

    let(:derivative) { '1234-0-access.mp3' }
    let(:wrong_presenter) { instance_double(Hyrax::FileSetPresenter) }
    let(:right_presenter) { instance_double(Hyrax::FileSetPresenter) }
    let(:presenters) { [wrong_presenter, wrong_presenter, right_presenter, wrong_presenter] }
    let(:right_name) { 'correct_name' }
    let(:wrong_name) { 'correct_name' }
    let(:right_id) { '1234' }
    let(:wrong_id) { '5678' }

    before do
      allow(wrong_presenter).to receive(:id).and_return(wrong_id)
      allow(wrong_presenter).to receive(:original_filenames).and_return([wrong_name])
      allow(right_presenter).to receive(:id).and_return(right_id)
      allow(right_presenter).to receive(:original_filenames).and_return([right_name])
    end

    it { is_expected.to eq right_name }
  end
end
