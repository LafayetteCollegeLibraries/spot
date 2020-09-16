# frozen_string_literal: true
RSpec.describe Spot::OaiCollectionSolrSet do
  before do
    described_class.fields = fields
  end

  let(:fields) { [{ label: 'Collection', solr_field: 'member_of_collections_ssim' }] }

  describe '.from_spec' do
    subject(:solr_filter) { described_class.from_spec(spec) }

    context 'when a spec has underscores in it' do
      let(:spec) { 'Collection:A_Test_Collection' }

      it 'replaces them with spaces' do
        expect(solr_filter).to eq 'member_of_collections_ssim:"A Test Collection"'
      end
    end

    context 'when a spec has no spaces' do
      let(:spec) { 'Collection:Photographs' }

      it 'does nothing' do
        expect(solr_filter).to eq 'member_of_collections_ssim:"Photographs"'
      end
    end
  end

  describe '#initialize' do
    subject(:solr_set) { described_class.new(spec) }

    let(:spec) { 'Collection:A_Test_Collection' }

    it 'replaces underscores with spaces for the @value property' do
      expect(solr_set.value).to eq 'A Test Collection'
    end

    it 'puts the underscores back when calling #spec' do
      expect(solr_set.spec).to eq spec
    end
  end
end
