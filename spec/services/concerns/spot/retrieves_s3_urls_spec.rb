# frozen_string_literal: true
# Tests to make sure that browse everything can read s3 urls
#
RSpec.describe BrowseEverything::Retriever do
  subject(:service) { described_class.new }

  it_should_behave_like "BrowseEverything::Retriever"

  describe '#can_retrieve?' do
    let(:uri) { 's3://bulkrax-imports/test.csv' }

    it 'evaluates a url' do
      expect(service.can_retrieve?(:uri, headers = {})).to be true
    end
  end
end