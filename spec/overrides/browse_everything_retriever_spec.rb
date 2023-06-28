# frozen_string_literal: true
# Tests to make sure that browse everything can read s3 urls
# Test format is copied from original Browse Everything tests
#
RSpec.describe BrowseEverything::Retriever do
  subject(:retriever) { described_class.new }

  describe '#get_file_size' do
    subject(:computed_file_size) { retriever.file_size(options) }

    let(:url) { URI.parse("s3://bulkrax-imports/test.csv") }
    let(:headers) { {} }
    let(:file_size) { 0 }
    let(:options) do
      {
        url: url,
        headers: headers,
        file_size: file_size
      }.with_indifferent_access
    end

    before do
      ENV['AWS_ACCESS_KEY_ID'] = 'test_user'
      ENV['AWS_SECRET_ACCESS_KEY'] = 'test_password'
      ENV['AWS_REGION'] = 'us-east-1'
    end

    context 'when retrieving a resource from Amazon s3' do
      let(:url) { URI.parse('s3://bulkrax-imports/test.csv') }

      before do
        stub_request(
          :head, "https://s3.amazonaws.com/bulkrax-imports//test.csv"
        ).and_return(
          headers: {
            'Content-Length' => '8'
          }
        )

        stub_request(
          :get, "https://s3.amazonaws.com/bulkrax-imports//test.csv"
        ).and_return(
          headers: {
            'Content-Length' => '8'
          },
          body: 'contents'
        )
      end

      it 'calculates or retrieves the size of a file' do
        retriever.retrieve(options) do |_chunk, _retrieved, total|
          expect(total).to eq 1234
        end
      end
    end
  end

  describe '.can_retrieve?' do
    context 'when can retrieve S3' do
      let(:url) { 'http://bulkrax-imports.s3.amazonaws.com/' }
      before do
        stub_request(
          :get, "http://bulkrax-imports.s3.amazonaws.com/"
        ).to_return(
          status: 206,
          body: '%'
        )
      end

      it 'says it can' do
        expect(described_class).to be_can_retrieve(url)
      end
    end
  end
end
