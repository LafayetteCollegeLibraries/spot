# frozen_string_literal: true
RSpec.describe Spot::CollectionsIndexSearchBuilder do
  describe '.default_processor_chain' do
    subject { described_class.default_processor_chain }

    it { is_expected.to include :only_include_top_level_collections }
  end

  describe '#only_include_top_level_collections' do
    subject(:solr_params) { described_class.new([]).with({}) }

    it 'excludes subcollections' do
      expect(solr_params['fq']).to include '-member_of_collection_ids_ssim:[* TO *]'
    end
  end
end
