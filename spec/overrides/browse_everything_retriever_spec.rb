# frozen_string_literal: true
# Tests to make sure that browse everything can read s3 urls
# Test format is copied from original Browse Everything tests 
#
RSpec.describe BrowseEverything::Retriever do
  subject(:service) { described_class.new }

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

    context 'when retrieving a resource from Amazon s3' do
      let(:url) { URI.parse('s3://bulkrax-imports/test.csv') }

      before do
        stub_request(
          :head, "http://bulkrax-imports.s3.amazonaws.com/"
        ).and_return(
          headers: {
            'Content-Length' => '1234'
          }
        )

        stub_request(
          :get, "http://bulkrax-imports.s3.amazonaws.com/"
        ).and_return(
          headers: {
            'Content-Length' => '1234'
          },
          body: 'content'
        )
      end

      it 'calculates or retrieves the size of a file' do
        retriever.retrieve(options) do |_chunk, _retrieved, total|
          expect(total).to eq 1234
        end
      end
    end
  end
end
