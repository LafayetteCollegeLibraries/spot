# frozen_string_literal: true
#
# we're only testing additions we make onto the +Hyrax::CollectionIndexer+
# that serves as the base class. see Hyrax for those specs.
RSpec.describe Spot::CollectionIndexer do
  subject(:solr_doc) { indexer.generate_solr_document }

  # note: we're using 'work' here as the 'indexes ISO language and label'
  # shared example requires that variable.
  let(:work) { Collection.new(metadata) }
  let(:indexer) { described_class.new(work) }
  let(:metadata) { { title: ['A Great Collection'] } }

  it_behaves_like 'it indexes ISO language and label'

  describe 'title sort' do
    it 'indexes the first title, downcased' do
      expect(solr_doc['title_sort_si']).to eq work.title.first.to_s.downcase
    end
  end
end
