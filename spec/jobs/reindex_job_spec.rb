# frozen_string_literal: true
RSpec.describe ReindexJob do
  before do
    allow(RdfLabel).to receive(:destroy_all)
    allow(ActiveFedora::Base).to receive(:reindex_everything)
  end

  it 'clears out RdfLabel cache and calls .reindex_everything' do
    described_class.perform_now

    expect(RdfLabel).to have_received(:destroy_all).exactly(1).time
    expect(ActiveFedora::Base).to have_received(:reindex_everything).exactly(1).time
  end
end
