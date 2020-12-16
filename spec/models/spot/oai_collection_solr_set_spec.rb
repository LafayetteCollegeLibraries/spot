# frozen_string_literal: true
RSpec.describe Spot::OaiCollectionSolrSet do
  before do
    described_class.fields = fields
    solr_docs.each { |doc| ActiveFedora::SolrService.add(doc) }
    ActiveFedora::SolrService.commit
  end

  after do
    solr_docs.each { |doc| ActiveFedora::SolrService.delete(doc[:id]) }
  end

  let(:fields) { [{ label: 'collection', solr_field: 'member_of_collection_ids_ssim' }] }
  let(:solr_docs) do
    [
      { id: 'collection_1', has_model_ssim: ['Collection'], read_access_group_ssim: ['public'],
        title_tesim: ['Cool Collection #1'] },
      { id: 'work_1', has_model_ssim: ['Publication'], read_access_group_ssim: ['public'],
        title_tesim: ['Cool Work'], member_of_collection_ids_ssim: ['collection_1'] },
      { id: 'work_2', has_model_ssim: ['Publication'], read_access_group_ssim: ['public'],
        title_tesim: ['Cool Work pt 2'], member_of_collection_ids_ssim: ['collection_2'] },
      { id: 'collection_2', has_model_ssim: ['Collection'], read_access_group_ssim: ['public'],
        title_tesim: ['Collection #2'] },
      { id: 'work_3', has_model_ssim: ['Image'], read_access_group_ssim: ['public'],
        title_tesim: ['An Image'], membber_of_collection_ids_ssim: ['collection_2'] }
    ]
  end

  describe '.from_spec' do
    subject(:solr_filter) { described_class.from_spec(spec) }

    let(:spec) { 'collection:abc123def' }

    it 'creates a solr_query using the id sent' do
      expect(solr_filter).to eq 'member_of_collection_ids_ssim:"abc123def"'
    end
  end

  describe '#name' do
    subject { described_class.new('collection:collection_1').name }

    it { is_expected.to eq 'Collection: Cool Collection #1' }
  end
end
