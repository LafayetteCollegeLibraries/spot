# frozen_string_literal: true

RSpec.describe Spot::UpdateSolrSuggestDictionariesJob do
  before do
    allow(Qa::Authorities::SolrSuggest).to receive(:build_dictionaries!)
  end

  it 'calls the SolrSuggest.build_dictionaries! method' do
    described_class.perform_now
    expect(Qa::Authorities::SolrSuggest).to have_received(:build_dictionaries!)
  end
end
