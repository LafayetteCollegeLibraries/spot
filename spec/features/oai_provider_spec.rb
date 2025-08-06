# frozen_string_literal: true
RSpec.feature 'OAI-PMH provider (via Blacklight)', clean: true do
  include_context 'Capybara host'

  before do
    objects.each { |obj| Hyrax::SolrService.add(obj) }
    Hyrax::SolrService.commit
  end

  after do
    objects.each { |obj| Hyrax::SolrService.delete_by_query("id:#{obj[:id]}") }
    Hyrax::SolrService.commit
  end

  let(:xml) { Nokogiri::XML(page.body) }
  let(:collection_class) { Hyrax.config.collection_class.to_s }
  let(:work_class) { Hyrax.config.use_valkyrie? ? 'PublicationResource' : 'Publication' }

  describe 'verb=ListSets' do
    let(:objects) { [col_1, col_2, item_1, item_2] }

    let(:col_1) do
      { id: 'col_1', has_model_ssim: [collection_class], title_tesim: ['Test Collection'],
        read_access_group_ssim: ['public'], discover_access_group_ssim: ['public'] }
    end
    let(:col_2) do
      { id: 'col_2', has_model_ssim: [collection_class], title_tesim: ['Another Collection'],
        read_access_group_ssim: ['private'] }
    end

    let(:item_1) do
      { id: 'item_1', has_model_ssim: [work_class], title_tesim: ['Item 1'],
        read_access_group_ssim: ['public'], discover_access_group_ssim: ['public'],
        member_of_collection_ids_ssim: ['col_1'] }
    end

    let(:item_2) do
      { id: 'item_2', has_model_ssim: [work_class], title_tesim: ['Item 2'],
        read_access_group_ssim: ['private'], member_of_collection_ids_ssim: ['col_2'] }
    end

    it 'only returns public items' do
      visit oai_catalog_path(verb: 'ListSets')

      values = xml.css('ListSets setSpec').map(&:text)

      expect(values).to include('collection_id:col_1')
      expect(values).not_to include('collection_id:col_2')
    end
  end

  describe 'verb=ListIdentifiers' do
    let(:objects) { [item_4, item_5] }
    let(:item_4) do
      { id: 'item_4', alternate_identifier_ssim: ['item_4'], has_model_ssim: [work_class], read_access_group_ssim: ['public'], member_of_collection_ids_ssim: ['col_1'] }
    end
    let(:item_5) do
      { id: 'item_5', alternate_identifier_ssim: ['item_4'], has_model_ssim: [work_class], read_access_group_ssim: ['public'] }
    end

    let(:prefixed_ids) { objects.map { |o| "oai:ldr:#{o[:id]}" } }

    it 'lists identifiers of all items' do
      visit oai_catalog_path(verb: 'ListIdentifiers', metadata_prefix: 'oai_dc')

      expect(xml.css('identifier').map(&:text)).to eq prefixed_ids
    end

    it 'lists identifiers by a set when provided' do
      visit oai_catalog_path(verb: 'ListIdentifiers', metadata_prefix: 'oai_dc', set: 'collection_id:col_1')

      expect(xml.css('identifier').map(&:text)).to eq ['oai:ldr:item_4']
    end
  end
end
