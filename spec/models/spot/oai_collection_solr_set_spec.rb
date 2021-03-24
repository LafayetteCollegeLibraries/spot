# frozen_string_literal: true
RSpec.describe Spot::OaiCollectionSolrSet do
  before { described_class.fields = fields }

  let(:fields) { [{ label: 'Collection', solr_field: 'member_of_collections_ssim' }] }

  describe '.from_spec' do
    subject(:solr_filter) { described_class.from_spec(spec) }

    context 'when a spec has escaped characters in it' do
      let(:spec) { 'Collection:Uniform%2C+White+Neck-band+%26+Collar%2C+Without+Bow' }

      it 'replaces them with spaces' do
        expect(solr_filter).to eq 'member_of_collections_ssim:"Uniform, White Neck-band & Collar, Without Bow"'
      end
    end
  end

  describe '#initialize' do
    subject(:solr_set) { described_class.new(spec) }

    let(:spec) { 'Collection:A+Test+Collection' }

    it 'escapes the setspec' do
      expect(solr_set.value).to eq 'A Test Collection'
    end

    it 'puts the underscores back when calling #spec' do
      expect(solr_set.spec).to eq spec
    end
  end

  describe '#name' do
    subject(:solr_set) { described_class.new(spec) }

    let(:spec) { 'Collection:A+Test+Collection' }

    it 'uses the unescaped value' do
      expect(solr_set.name).to eq 'Collection: A Test Collection'
    end
  end
end
