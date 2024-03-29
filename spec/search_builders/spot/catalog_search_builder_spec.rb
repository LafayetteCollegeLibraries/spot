# frozen_string_literal: true
RSpec.describe Spot::CatalogSearchBuilder do
  describe '.default_processor_chain' do
    subject { described_class.default_processor_chain }

    it { is_expected.not_to include :show_works_or_works_that_contain_files }
    it { is_expected.to include :add_advanced_search_to_solr }
    it { is_expected.to include :add_full_text_context }
  end

  describe '#add_full_text_context' do
    subject(:context_query) { builder.add_full_text_context(params) }

    let(:builder) { described_class.new([]).with(blacklight_params) }
    let(:blacklight_params) { { q: 'a cool query' } }
    let(:feature_available) { true }
    let(:params) { {} }

    it 'enables highlighting for the extracted_text field' do
      context_query # need to kick it off first

      expect(params['hl']).to be true
      expect(params['hl.fl']).to eq ['extracted_text_tsimv']
    end

    context 'when the query is empty' do
      let(:blacklight_params) { {} }

      it { is_expected.to be_nil }
    end
  end
end
