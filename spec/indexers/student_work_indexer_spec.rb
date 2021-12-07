# frozen_string_literal: true
RSpec.describe StudentWorkIndexer do
  include_context 'indexing'

  it_behaves_like 'a Spot indexer'
  it_behaves_like 'it indexes a sortable date'
end
