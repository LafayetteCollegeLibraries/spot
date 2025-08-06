# frozen_string_literal: true

RSpec.describe CatalogController, clean: true do
  describe '#index' do
    before do
      objects.each { |obj| ActiveFedora::SolrService.add(obj) }
      ActiveFedora::SolrService.commit
    end

    after do
      objects.each { |obj| ActiveFedora::SolrService.delete(id: obj[:id]) }
      ActiveFedora::SolrService.commit
    end

    context 'all_fields search field' do
      let(:objects) { [all_1, all_2, all_3, all_4] }

      let(:all_1) do
        { id: 'all_1', has_model_ssim: ['Publication'],
          title_tesim: ['Cool Cats'], read_access_group_ssim: ['public'] }
      end

      let(:all_2) do
        { id: 'all_2', has_model_ssim: ['Publication'],
          creator_tesim: ['Person, Cool'], read_access_group_ssim: ['public'] }
      end

      let(:all_3) do
        { id: 'all_3', has_model_ssim: ['Publication'],
          abstract_tesim: ['A report about cooling systems'], read_access_group_ssim: ['public'] }
      end

      let(:all_4) do
        { id: 'all_4', has_model_ssim: ['Publication'],
          extracted_text_tsimv: ['this is a pretty cool captured phrase'],
          read_access_group_ssim: ['public'] }
      end

      let(:expected_ids) { [all_1[:id], all_2[:id], all_3[:id], all_4[:id]] }

      it 'finds objects with "cool" somewhere in a *_tesim field' do
        get :index, params: { q: 'cool*', search_field: 'all_fields' }
        expect(assigns(:document_list).map(&:id)).to contain_exactly(*expected_ids)
      end
    end

    context 'title search field' do
      let(:objects) { [title_1, title_2, title_3, title_4] }

      let(:title_1) do
        { id: 'title_1', has_model_ssim: ['Publication'],
          title_tesim: ['example title'], read_access_group_ssim: ['public'] }
      end

      let(:title_2) do
        { id: 'title_2', has_model_ssim: ['Publication'],
          subtitle_tesim: ['has a title'], read_access_group_ssim: ['public'] }
      end

      let(:title_3) do
        { id: 'title_3', has_model_ssim: ['Publication'],
          title_alternative_tesim: ['has a title'], read_access_group_ssim: ['public'] }
      end

      let(:title_4) do
        { id: 'title_4', has_model_ssim: ['Publication'],
          title_tesim: ['nope nothing here'], read_access_group_ssim: ['public'] }
      end

      let(:expected_ids) { [title_1[:id], title_2[:id], title_3[:id]] }

      it 'finds works with matching title fields' do
        get :index, params: { q: 'title', search_field: 'title' }
        expect(assigns(:document_list).map(&:id)).to contain_exactly(*expected_ids)
      end
    end

    context 'author search field' do
      let(:objects) { [author_1, author_2, author_3, author_4] }

      let(:author_1) do
        { id: 'author_1', has_model_ssim: ['Publication'],
          creator_tesim: ["O'Hara, Frank"], read_access_group_ssim: ['public'] }
      end

      let(:author_2) do
        { id: 'author_2', has_model_ssim: ['Publication'],
          contributor_tesim: ["O'Hara, Cathleen"], read_access_group_ssim: ['public'] }
      end

      let(:author_3) do
        { id: 'author_3', has_model_ssim: ['Publication'],
          editor_tesim: ["O'Hara, Asia"], read_access_group_ssim: ['public'] }
      end

      let(:author_4) do
        { id: 'author_4', has_model_ssim: ['Publication'],
          title_tesim: ["Famous O'Haras"], read_access_group_ssim: ['public'] }
      end

      let(:expected_ids) { [author_1[:id], author_2[:id], author_3[:id]] }

      it 'finds works with matching authors' do
        get :index, params: { q: "o'hara", search_field: 'author' }
        expect(assigns(:document_list).map(&:id)).to contain_exactly(*expected_ids)
      end
    end

    context 'all_fields with english language dates' do
      let(:objects) { [obj1, obj2] }

      let(:obj1) do
        { id: 'all_field_obj_1', has_model_ssim: ['Publication'],
          english_language_date_teim: ['Spring 2019'],
          read_access_group_ssim: ['public'] }
      end

      let(:obj2) do
        { id: 'all_field_obj_2', has_model_ssim: ['Publication'],
          english_language_date_teim: ['Autumn 2019', 'Fall 2019'],
          read_access_group_ssim: ['public'] }
      end

      it 'returns seasonal items' do
        get :index, params: { q: 'spring', search_field: 'all_fields' }
        expect(assigns(:document_list).map(&:id)).to contain_exactly(obj1[:id])
      end
    end

    context 'full-text search' do
      let(:objects) { [ft_1, ft_2] }

      let(:ft_1) do
        { id: 'full_text_1', has_model_ssim: ['Publication'],
          title_tesim: ['no not here'], read_access_group_ssim: ['public'] }
      end

      let(:ft_2) do
        { id: 'full_text_2', has_model_ssim: ['Publication'],
          title_tesim: ['ok!'], extracted_text_tsimv: ['Now see here, this oughta show up!'],
          read_access_group_ssim: ['public'] }
      end

      it 'only searches the extracted_text_tsimv field' do
        get :index, params: { q: 'here', search_field: 'full_text' }
        expect(assigns(:document_list).map(&:id)).to contain_exactly(ft_2[:id])
      end
    end
  end

  describe '#oai' do
    subject(:oai_response) { get :oai, params: oai_params }
    let(:xml) { Nokogiri::XML(oai_response.body) }

    describe 'verb=GetRecord' do
      include_context 'mock GeoNames RDF response'

      before do
        # @note I tried oveerriding this a step lower with
        # allow(Hyrax.query_service.custom_queries).to receive(:find_child_file_sets)
        # but was running into issues with the mock not taking, so here we are.
        allow_any_instance_of(PublicationResourceIndexer)
          .to receive(:file_set_mime_types)
          .and_return([mock_mime_type])
      end

      after do
        Hyrax.persister.delete(resource: work)
      end

      let(:oai_params) { { verb: 'GetRecord', identifier: "oai:ldr:#{original_work.id}", metadataPrefix: 'oai_dc' } }
      let(:mock_file_set) { instance_double('Hyrax::FileSet') }
      let(:mock_mime_type) { 'application/pdf' }
      let(:work) { Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: original_work.id) }

      let(:original_work) do
        if Hyrax.config.use_valkyrie?
          FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only, :public, **metadata)
        else
          FactoryBot.create(:publication, :public, **metadata)
        end
      end

      let(:metadata) do
        {
          contributor: ['Contributor A', 'Contributor B'],
          creator: ['Creator, Anne'],
          date_issued: ['2025-05-22'],
          description: ['A description of the resource'],
          location: [mock_geonames_uri]
        }
      end
      let(:dc_uri) { 'http://purl.org/dc/elements/1.1/' }
      let(:location_label) do
        name, admin_name, country_name = mock_geonames_response.values_at(:name, :adminName1, :countryName)
        "#{name}, #{admin_name}, #{country_name}"
      end

      it 'displays DC metadata of the indexed object' do
        expect(xml.xpath('//dc:contributor', dc: dc_uri).map(&:text)).to eq work.contributor
        expect(xml.xpath('//dc:coverage', dc: dc_uri).map(&:text)).to eq [location_label]
        expect(xml.xpath('//dc:creator', dc: dc_uri).map(&:text)).to eq work.creator
        expect(xml.xpath('//dc:date', dc: dc_uri).map(&:text)).to eq work.date_issued
        expect(xml.xpath('//dc:description', dc: dc_uri).map(&:text)).to eq work.description
        expect(xml.xpath('//dc:format', dc: dc_uri).map(&:text)).to eq [mock_mime_type]
      end
    end

    describe 'verb=ListSets' do
      let(:oai_params) { { verb: 'ListSets' } }

      before do
        [col_1, col_2].each do |obj|
          next obj.save! if obj.respond_to?(:save!)
          Hyrax.persister.save(resource: obj)
        end

        item_1.member_of_collection_ids = [col_1.id]
        item_2.member_of_collection_ids = [col_2.id]

        [item_1, item_2].each { |item| Hyrax.persister.save(resource: item) }
      end

      after do
        [col_1, col_2, item_1, item_2].each do |obj|
          next obj.destroy if obj.respond_to?(:delete!)
          Hyrax.persister.delete(resource: obj)
        end
      end

      let(:collection_class) { Hyrax.config.collection_class }

      let(:col_1) do
        collection_class.new(title: ['First Collection'],
                             visibility: 'open',
                             collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.to_global_id)
      end

      let(:col_2) do
        collection_class.new(title: ['Second Collection'],
                             visibility: 'restricted',
                             collection_type_gid: Hyrax::CollectionType.find_or_create_default_collection_type.to_global_id)
      end

      let(:metadata_1) do
        {
          alternate_ids: ['work_1'],
          title: ['Work 1'],
          date_issued: ['2025-05'],
          resource_type: ['Postcard'],
          rights_statement: ['http://rightsstatements.org/vocab/NKC/1.0/'],
          visibility: 'open'
        }
      end

      let(:metadata_2) do
        {
          alternate_ids: ['work_2'],
          title: ['Work 2'],
          date_issued: ['2025-05'],
          resource_type: ['Postcard'],
          rights_statement: ['http://rightsstatements.org/vocab/NKC/1.0/'],
          visibility: 'restricted'
        }
      end

      let(:item_1) do
        if Hyrax.config.use_valkyrie?
          FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only, :public, **metadata_1)
        else
          FactoryBot.create(:publication, :public, **metadata_1)
        end
      end

      let(:item_2) do
        if Hyrax.config.use_valkyrie?
          FactoryBot.valkyrie_create(:publication_resource_with_required_fields_only, :public, **metadata_2)
        else
          FactoryBot.create(:publication, :public, **metadata_2)
        end
      end

      it 'only returns public items' do
        values = xml.css('ListSets setSpec').map(&:text)

        expect(values).to include("collection_id:#{col_1.id}")
        expect(values).not_to include("collection_id:#{col_2.id}")
      end
    end
  end
end
