# frozen_string_literal: true
RSpec.describe Qa::Authorities::PublisherSuggest do
  it_behaves_like 'a Solr suggestion authority' do
    let(:solr_field) { 'publisher_sim' }
  end

  it_behaves_like 'it no-ops #term'
  it_behaves_like 'it no-ops #all'

  describe '.suggestion_dictionary' do
    subject { described_class.suggestion_dictionary }

    it { is_expected.to eq 'publisherSuggester' }
  end
end
