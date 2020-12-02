# frozen_string_literal: true
RSpec.describe Spot::ParentCollectionsSearchBuilder do
  let(:solr_params) { builder.to_h }
  let(:builder) { described_class.new(scope).with({}) }
  let(:scope) { OpenStruct.new(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }
  let(:ability) { ::Ability.new(user) }
  let(:user) { create(:public_user) }

  describe '.default_processor_chain' do
    subject { described_class.default_processor_chain }

    it { is_expected.to include :only_include_top_level_collections }
  end

  describe '#sort_field' do
    subject { builder.sort_field }

    it { is_expected.to eq 'title_sort_si' }
  end

  describe '#only_include_top_level_collections' do
    it 'excludes subcollections' do
      expect(solr_params['fq']).to include('-member_of_collection_ids_ssim:[* TO *]')
    end
  end
end
