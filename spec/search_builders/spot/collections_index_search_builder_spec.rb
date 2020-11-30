# frozen_string_literal: true
RSpec.describe Spot::CollectionsIndexSearchBuilder do
  let(:scope) do
    OpenStruct.new(blacklight_config: CatalogController.blacklight_config, current_ability: ability)
  end

  let(:user) { create(:public_user) }
  let(:ability) { ::Ability.new(user) }

  describe '.default_processor_chain' do
    subject { described_class.default_processor_chain }

    it { is_expected.to include :only_include_top_level_collections }
  end

  describe '#only_include_top_level_collections' do
    let(:solr_params) { builder.to_h }
    let(:builder) { described_class.new(scope).with({}) }

    it 'excludes subcollections' do
      expect(solr_params['fq']).to include('-member_of_collection_ids_ssim:[* TO *]')
    end
  end
end
