# frozen_string_literal: true
# Tests to make sure that browse everything can read s3 urls
# Test format is copied from original Browse Everything tests
#
RSpec.describe BrowseEverything::Retriever do
  subject(:retriever) { described_class.new }

  describe '#get_file_size' do
    let(:s3_bucket) { 'bulkrax-imports-bucket' }
    let(:s3_key) { '/project-name/files/file01.tif' }
    let(:url) { "s3://#{s3_bucket}#{s3_key}" }
    let(:mock_s3_client) { instance_double(Aws::S3::Client) }
    let(:mock_s3_response) { instance_double(Aws::S3::Types::HeadObjectOutput) }
    let(:file_size) { 1234 }
    let(:headers) { {} }
    let(:options) do
      {
        url: url,
        headers: headers,
        file_size: 0
      }.with_indifferent_access
    end

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
      allow(mock_s3_client).to receive(:head_object).with(bucket: s3_bucket, key: s3_key).and_return(mock_s3_response)
      allow(mock_s3_response).to receive(:content_length).and_return(file_size)
    end

    it 'returns the correct size' do
      expect(retriever.send(:get_file_size, options)).to eq file_size
    end
  end

  # describe '.can_retrieve?' do
  #   let(:s3_bucket) { 'bulkrax-imports-bucket' }
  #   let(:s3_key) { '/project-name/files/file01.tif' }
  #   let(:url) { "s3://#{s3_bucket}#{s3_key}" }
  #   let(:mock_s3_client) { instance_double(Aws::S3::Client) }
  #   let(:mock_s3_response) { instance_double(Aws::S3::Types::HeadObjectOutput) }

  #   context 'when can retrieve S3' do
  #     before do
  #       allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
  #       allow(mock_s3_client).to receive(:head_object).with(bucket: s3_bucket, key: s3_key).and_return(mock_s3_response)
  #       allow(mock_s3_client).to receive(:get_object).with(bucket: s3_bucket, key: s3_key).and_return(mock_s3_response)
  #     end

  #     it 'says it can' do
  #       expect(described_class).to be_can_retrieve(url)
  #     end
  #   end

  #   context 'when can not retrieve S3' do
  #     before do
  #       allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
  #       allow(mock_s3_client).to receive(:head_object).with(bucket: s3_bucket, key: s3_key).and_return(nil)
  #       allow(mock_s3_client).to receive(:get_object).with(bucket: s3_bucket, key: s3_key).and_return(mock_s3_response)
  #     end

  #     it 'says it can not' do
  #       expect(described_class).not_to be_can_retrieve(url)
  #     end
  #   end
  # end

  describe '#retrieve' do
    let(:s3_bucket) { 'bulkrax-imports-bucket' }
    let(:s3_key) { '/project-name/files/file01.tif' }
    let(:s3_url) { "s3://#{s3_bucket}#{s3_key}" }
    let(:mock_s3_client) { instance_double(Aws::S3::Client) }
    let(:mock_chunk) { instance_double(String, bytesize: chunk_size) }
    let(:chunk_size) { 5 }
    let(:file_size) { 1234 }

    # even though we're not using it in our s3 implementation,
    # defining a file_size in the options allows us to bypass
    # the get_file_size call
    let(:retrieve_options) do
      { 'url' => s3_url, 'file_size' => file_size, 'headers' => {} }
    end

    # if the args passed to mock_s3_client don't match the ones explicitly defined
    # by the "allow()" call below, the test will fail.
    before do
      allow(Aws::S3::Client).to receive(:new).and_return(mock_s3_client)
      allow(mock_s3_client).to receive(:get_object).with(bucket: s3_bucket, key: s3_key).and_yield(mock_chunk)
    end

    context 'when passed an s3 url' do
      it 'retrieves and yields a chunk of the object to the block' do
        retriever.retrieve(retrieve_options) do |chunk, current_size, total_size|
          expect(chunk).to be mock_chunk         # yields the chunk from s3_client.get_object
          expect(current_size).to be chunk_size  # yields the size in progress (increases with each chunk)
          expect(total_size).to eq file_size     # yields the total file size
        end

        expect(mock_chunk).to have_received(:bytesize)
      end
    end
  end
end
