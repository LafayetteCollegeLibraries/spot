# frozen_string_literal: true
RSpec.feature 'OAI-PMH provider (via Blacklight)' do
  before do
    ActiveFedora::SolrService.instance.conn.tap do |conn|
      query = Hyrax.config.curation_concerns.map { |m| "has_model_ssim:#{m}" }.join(' OR ')
      conn.delete_by_query("(#{query})", params: { 'softCommit' => true })
    end

    objects.each { |obj| ActiveFedora::SolrService.add(obj) }
    ActiveFedora::SolrService.commit
  end

  # clear out the objects
  after do
    ActiveFedora::SolrService.instance.conn.tap do |conn|
      obj_query = objects.map { |o| "id:#{o[:id]}" }.join(' OR ')
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
      { contributor_tesim: contributor, creator_tesim: creator,
        date_issued_ssim: date, description_tesim: description,
        file_format_ssim: format, language_ssim: language,
        location_label_ssim: location, permalink_ss: permalink,
        publisher_tesim: publisher, resource_type_tesim: type,
        rights_statement_ssim: rights, source_tesim: source,
        subject_label_ssim: subjects, thumbnail_url_ss: thumbail_url,
        title_tesim: title }
    end
    let(:contributor) { ['Contributor 1', 'Contributor 2'] }
    let(:creator) { ['Creator 1', 'Creator 2'] }
    let(:date) { ['2019-11-05'] }
    let(:description) { ['Describing the thing'] }
    let(:format) { ['application/pdf'] }
    let(:language) { ['en'] }
    let(:location) { ['Easton, Pennsylvania, United States'] }
    let(:publisher) { ['Some Good Publisher'] }
    let(:rights) { ['http://ok-go-ahead-and-use-it.org'] }
    let(:source) { ['The Source'] }
    let(:title) { ['Item 3'] }
    let(:type) { ['Periodical'] }
    let(:permalink) { 'https://ldr.lafayette.edu/path/to/object' }
    let(:thumbnail_url) { 'https://ldr.lafayette.edu/downloads/fsabc123?file=thumbnail' }
    let(:subjects) { ['Little libraries'] }
    let(:dc_uri) { 'http://purl.org/dc/elements/1.1/' }

    it 'translates solr values to dc terms' do
      visit oai_catalog_path(verb: 'GetRecord', metadataPrefix: 'oai_dc', identifier: 'oai:ldr:item_3')

      expect(xml.xpath('//dc:contributor', dc: dc_uri).map(&:text)).to eq contributor
      expect(xml.xpath('//dc:coverage', dc: dc_uri).map(&:text)).to eq location
      expect(xml.xpath('//dc:creator', dc: dc_uri).map(&:text)).to eq creator
      expect(xml.xpath('//dc:date', dc: dc_uri).map(&:text)).to eq date
      expect(xml.xpath('//dc:description', dc: dc_uri).map(&:text)).to eq description
      expect(xml.xpath('//dc:format', dc: dc_uri).map(&:text)).to eq format
      expect(xml.xpath('//dc:identifier', dc: dc_uri).map(&:text))
        .to include permalink, thumbnail_url, 'item_3'
      expect(xml.xpath('//dc:publisher', dc: dc_uri).map(&:text)).to eq publisher
      expect(xml.xpath('//dc:rights', dc: dc_uri).map(&:text)).to eq rights
      expect(xml.xpath('//dc:source', dc: dc_uri).map(&:text)).to eq source
      expect(xml.xpath('//dc:subject', dc: dc_uri).map(&:text)).to eq subjects
      expect(xml.xpath('//dc:title', dc: dc_uri).map(&:text)).to eq title
      expect(xml.xpath('//dc:type', dc: dc_uri).map(&:text)).to eq type
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
