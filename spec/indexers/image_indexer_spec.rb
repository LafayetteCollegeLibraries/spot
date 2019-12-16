# frozen_string_literal: true
RSpec.describe ImageIndexer do
  include_context 'indexing'

  it_behaves_like 'a Spot indexer'

  describe 'sortable date' do
    let(:work) { build(:image, date: ['2019-12?']) }

    it 'parses a sortable date' do
      expect(solr_doc['date_sort_dtsi']).to eq '2019-12-01T00:00:00Z'
    end
  end
end
