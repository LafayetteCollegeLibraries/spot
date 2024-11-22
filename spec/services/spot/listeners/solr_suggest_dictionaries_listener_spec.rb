# frozen_string_literal: true
RSpec.describe Spot::Listeners::SolrSuggestDictionariesListener, valkyrization: true do
  let(:listener) { described_class.new }

  describe '#on_object_metadata_updated' do
    before do
      allow(Spot::UpdateSolrSuggestDictionariesJob).to receive(:perform_now)
    end

    it 'calls Spot::UpdateSolrSuggestDictionariesJob' do
      listener.on_object_metadata_updated(object: nil, user: nil)

      expect(Spot::UpdateSolrSuggestDictionariesJob).to have_received(:perform_now).exactly(1).time
    end
  end
end
