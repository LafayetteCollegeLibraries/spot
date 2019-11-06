# frozen_string_literal: true
RSpec.feature 'OAI-PMH provider (via Blacklight)' do
  before do
    objects.each { |obj| ActiveFedora::SolrService.add(obj) }
    ActiveFedora::SolrService.commit
  end

  # clear out the objects
  after do
    obj_query = objects.map { |o| "id:#{o[:id]}" }.join(' OR ')
    ActiveFedora::SolrService.instance.conn.tap do |conn|
      conn.delete_by_query("(#{obj_query})", params: { 'softCommit' => true })
    end
  end

  let(:xml) { Nokogiri::XML(page.body) }

  describe 'verb=ListSets' do
    let(:objects) { [item_1, item_2] }

    let(:item_1) do
      { id: 'item_1', has_model_ssim: ['Publication'], title_tesim: ['Item 1'],
        read_access_group_ssim: ['public'], member_of_collections_ssim: ['Collection 1'] }
    end

    let(:item_2) do
      { id: 'item_2', has_model_ssim: ['Publication'], title_tesim: ['Item 2'],
        member_of_collections_ssim: ['Collection 2'] }
    end

    it 'only returns public items' do
      visit oai_catalog_path(verb: 'ListSets')

      values = xml.css('ListSets setSpec').map(&:text)
      expect(values).to include('collection:Collection 1')
      expect(values).not_to include('collection:Collection 2')
    end
  end

  describe 'verb=GetRecord' do
    let(:objects) { [item_3] }
    let(:item_3) do
      { id: 'item_3', has_model_ssim: ['Publication'],
        read_access_group_ssim: ['public'] }.merge(metadata)
    end
    let(:metadata) do
      { title_tesim: title, creator_tesim: creator, contributor_tesim: contributor,
        date_issued_ssim: date, description_tesim: description }
    end
    let(:title) { ['Item 3'] }
    let(:creator) { ['Creator 1', 'Creator 2'] }
    let(:contributor) { ['Contributor 1', 'Contributor 2'] }
    let(:date) { ['2019-11-05'] }
    let(:description) { ['Describing the thing'] }
    let(:dc_uri) { 'http://purl.org/dc/elements/1.1/' }

    it 'translates solr values to dc terms' do
      visit oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc', identifier: 'oai:ldr:item_3')

      expect(xml.xpath('//dc:title', dc: dc_uri).map(&:text)).to eq title
      expect(xml.xpath('//dc:creator', dc: dc_uri).map(&:text)).to eq creator
      expect(xml.xpath('//dc:contributor', dc: dc_uri).map(&:text)).to eq contributor
      expect(xml.xpath('//dc:date', dc: dc_uri).map(&:text)).to eq date
      expect(xml.xpath('//dc:description', dc: dc_uri).map(&:text)).to eq description
    end
  end

  describe 'verb=ListIdentifiers' do
    let(:objects) { [item_4, item_5] }
    let(:item_4) do
      { id: 'item_4', has_model_ssim: ['Publication'],
        read_access_group_ssim: ['public'], member_of_collections_ssim: ['Collection 1'] }
    end
    let(:item_5) do
      { id: 'item_5', has_model_ssim: ['Publication'], read_access_group_ssim: ['public'] }
    end

    let(:prefixed_ids) { objects.map { |o| "oai:ldr:#{o[:id]}" } }

    it 'lists identifiers of all items' do
      visit oai_catalog_path(verb: 'ListIdentifiers', metadata_prefix: 'oai_dc')

      expect(xml.css('identifier').map(&:text)).to eq prefixed_ids
    end

    it 'lists identifiers by a set when provided' do
      visit oai_catalog_path(verb: 'ListIdentifiers', metadata_prefix: 'oai_dc', set: 'collection:Collection 1')

      expect(xml.css('identifier').map(&:text)).to eq ['oai:ldr:item_4']
    end
  end
end
