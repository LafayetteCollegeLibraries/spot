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
end
