# frozen_string_literal: true
RSpec.describe Spot::AwsAccessMasterService do
  def set_env!
    stub_env('AWS_ACCESS_KEY_ID', 'abc123')
    stub_env('AWS_ACCESS_MASTER_BUCKET', 'ldss-access-master-storage')
    stub_env('AWS_REGION', 'us-west-2')
    stub_env('AWS_SECRET_ACCESS_KEY', 'shh')
  end

  subject(:service) { described_class.new(valid_file_set) }

  let(:valid_file_set) { FileSet.new(id: 'fs-abc123') }

  before do
    set_env!

    allow(valid_file_set).to receive(:mime_type).and_return('image/jpeg')

    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Aws::S3::Client).to receive(:delete_object)
    allow_any_instance_of(Aws::S3::Client).to receive(:put_object)
    # rubocop:enable RSpec/AnyInstance
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

    let(:client) { service.send(:client) }

    it 'calls aws_client#delete_object' do
      service.cleanup_derivatives

      expect(client)
        .to have_received(:delete_object)
        .with(bucket: ENV['AWS_ACCESS_MASTER_BUCKET'], key: 'fs-abc123-access_master.tif')
    end

    context 'when not all ENV values are set' do
      before do
        allow(ENV).to receive(:[]).with('AWS_REGION').and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#create_derivatives' do
    let(:client) { service.send(:client) }
    let(:mocked_io) { StringIO.new('chunk') }
    let(:tmpdir_path) { '/tmpdir' }
    let(:filename) { '/path/to/tmp/file' }
    let(:magick_commands) do
      [].tap do |arr|
        arr.define_singleton_method(:merge!) do |args|
          args.each { |arg| self << arg }
        end
      end
    end
    let(:expected_magick_commands) do
      [
        filename,
        '-define',
        'tiff:tile-geometry=128x128',
        'ptif:/tmpdir/fs-abc123-access_master.tif'
      ]
    end
    let(:expected_payload) do
      {
        body: mocked_io, bucket: 'ldss-access-master-storage',
        content_md5: 'Wo9Poq6rVDGIjuihjOO86g==', key: 'fs-abc123-access_master.tif'
      }
    end

    before do
      allow(MiniMagick::Tool::Magick).to receive(:new).and_yield(magick_commands)
      allow(Dir).to receive(:mktmpdir).and_yield(tmpdir_path)
      allow(File)
        .to receive(:open)
        .with('/tmpdir/fs-abc123-access_master.tif', 'rb')
        .and_return(mocked_io)
    end

    it 'creates derivatives' do
      service.create_derivatives(filename)

      expect(magick_commands).to eq(expected_magick_commands)
      expect(client).to have_received(:put_object).with(expected_payload)
    end

    context 'when not all ENV values are set' do
      subject { service.create_derivatives(filename) }

      before do
        allow(ENV).to receive(:[]).with('AWS_REGION').and_return(nil)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#derivative_url' do
    subject { service.derivative_url }

    let(:url) { 'https://ldss-access-master-storage.s3.us-west-2.amazonaws.com/fs-abc123-access_master.tif' }

    it { is_expected.to eq url }
  end
end
