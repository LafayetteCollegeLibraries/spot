# frozen_string_literal: true
RSpec.describe Spot::AwsAccessMasterService do
  def set_env!
    stub_env('AWS_ACCESS_KEY_ID', 'abc123')
    stub_env('AWS_ACCESS_MASTER_BUCKET', 'ldss-access-master-storage')
    stub_env('AWS_REGION', 'us-west-2')
    stub_env('AWS_SECRET_ACCESS_KEY', 'shh')
  end

  def clear_env!
    %w(AWS_ACCESS_KEY_ID AWS_ACCESS_MASTER_BUCKET AWS_REGION AWS_SECRET_ACCESS_KEY).each do |env|
      stub_env(env, nil)
    end
  end

  subject(:service) { described_class.new(valid_file_set) }

  let(:valid_file_set) { FileSet.new(id: 'fs-abc123') }
  let(:aws_client) { instance_double(Aws::S3::Client) }
  let(:aws_config) do
    {
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
  end

  before do
    set_env!

    allow(valid_file_set).to receive(:mime_type).and_return('image/jpeg')
    allow(service).to receive(:client).and_return(aws_client)
  end

  it_behaves_like 'a Hyrax::DerivativeService'

  describe '.credentials_present?' do
    subject { described_class.credentials_present? }

    context 'when the values are present' do
      it { is_expected.to be true }
    end

    context 'when the values are not present' do
      before do
        allow(ENV).to receive(:[]).with('AWS_REGION').and_return(nil)
      end

      it { is_expected.to be false }
    end
  end

  describe '#cleanup_derivatives' do
    subject { service.cleanup_derivatives }

    before do
      allow(aws_client).to receive(:delete_object)
    end

    it 'calls aws_client#delete_object' do
      service.cleanup_derivatives

      expect(aws_client)
        .to have_received(:delete_object)
        .with(bucket: ENV['AWS_ACCESS_MASTER_BUCKET'], key: 'fs-abc123-access_master.tif')
    end

    context 'when ENV values are not set' do
      before { clear_env! }

      it { is_expected.to be_nil }
    end
  end

  describe '#create_derivatives' do
    subject { service.create_derivatives(filename) }

    let(:filename) { '/path/to/tmp/file' }

    skip 'creates derivatives' do
      # need to do _a lot_ of stubbing, i think
    end

    context 'when ENV values are not set' do
      before { clear_env! }

      it { is_expected.to be_nil }
    end
  end

  describe '#derivative_url' do
    subject { service.derivative_url }

    let(:url) { 'https://ldss-access-master-storage.s3.us-west-2.amazonaws.com/fs-abc123-access_master.tif' }

    it { is_expected.to eq url }
  end
end
