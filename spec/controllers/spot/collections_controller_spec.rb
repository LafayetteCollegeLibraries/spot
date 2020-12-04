# frozen_string_literal: true
RSpec.describe Spot::CollectionsController do
  before do
    objects.each { |obj| ActiveFedora::SolrService.add(obj) }
    ActiveFedora::SolrService.commit
  end

  describe '#index' do
    before { get :index }

    let(:objects) do
      [
        {
          id: 'collection_1',
          has_model_ssim: ['Collection'],
          title_tesim: ['Collection #1'],
          read_access_group_ssim: ['public'],
          member_of_collection_ids_ssim: []
        },
        {
          id: 'collection_2',
          has_model_ssim: ['Collection'],
          title_tesim: ['Collection #2'],
          read_access_group_ssim: ['public'],
          member_of_collection_ids_ssim: []
        },
        {
          id: 'subcollection_1',
          has_model_ssim: ['Collection'],
          title_tesim: ['Subcollection #1'],
          read_access_group_ssim: ['public'],
          member_of_collection_ids_ssim: ['collection_1']
        }
      ]
    end

    it 'renders the template' do
      expect(response).to render_template(:index)
    end

    it 'returns only top-level collections' do
      collections = assigns(:collections)

      expect(collections.count).to eq 2
      expect(collections.map(&:id)).to eq ['collection_1', 'collection_2']
    end
  end
end
