# frozen_string_literal: true
RSpec.shared_examples 'it indexes standard and local identifiers' do
  subject(:solr_doc) { indexer.generate_solr_document }

  let(:indexer) { described_class.new(work)}
  let(:work_klass) { described_class.name.gsub(/Indexer$/, '').downcase.to_sym }
  let(:work) { build(work_klass, identifier: identifier) }

  context 'when identifier is empty' do
    let(:identifier) { [] }

    it 'does nothing' do
      expect(solr_doc['identifier_standard_ssim']).to eq []
      expect(solr_doc['identifier_local_ssim']).to eq []
    end
  end

  context 'when local identifier is present' do
    let(:identifier) { ['lafayette:abc123'] }

    it 'indexes the value to the "identifier_local_ssim" field' do
      expect(solr_doc['identifier_local_ssim']).to eq ['lafayette:abc123']
      expect(solr_doc['identifier_standard_ssim']).to eq []
    end
  end

  context 'when a standard identifeir is present' do
    let(:identifier) { ['issn:1234-5678'] }

    it 'indexes the value to the "identifier_standard_ssim" field' do
      expect(solr_doc['identifier_standard_ssim']).to eq ['issn:1234-5678']
      expect(solr_doc['identifier_local_ssim']).to eq []
    end
  end

  context 'when both types of identifiers are present' do
    let(:identifier) { ['issn:1234-5678', 'lafayette:abc123'] }

    it 'indexes both to their respsective fields' do
      expect(solr_doc['identifier_standard_ssim']).to eq ['issn:1234-5678']
      expect(solr_doc['identifier_local_ssim']).to eq ['lafayette:abc123']
    end
  end
end
