# frozen_string_literal: true

RSpec.describe HandleController do
  describe '#show' do
    subject { get :show, params: { id: handle } }

    let(:solr_service) { ActiveFedora::SolrService }

    before do
      solr_service.add(solr_data)
      solr_service.commit
    end

    after do
      solr_service.delete(id: solr_data[:id])
      solr_service.commit
    end

    context 'when a Handle exists for a Publication' do
      let(:handle) { '10385/1234' }
      let(:solr_data) do
        {
          id: 'existing-pub',
          has_model_ssim: ['Publication'],
          identifier_ssim: ["hdl:#{handle}"]
        }
      end

      it { is_expected.to redirect_to hyrax_publication_path(solr_data[:id]) }
    end

    context 'when a Handle exists for an Image' do
      let(:handle) { '10385/5678' }
      let(:solr_data) do
        {
          id: 'existing-img',
          has_model_ssim: ['Image'],
          identifier_ssim: ["hdl:#{handle}"]
        }
      end

      it { is_expected.to redirect_to hyrax_image_path(solr_data[:id]) }
    end

    context 'when a Handle exists for an Image' do
      let(:handle) { '10385/5678' }
      let(:solr_data) do
        {
          id: 'existing-img',
          has_model_ssim: ['Image'],
          identifier_ssim: ["hdl:#{handle}"]
        }
      end

      it { is_expected.to redirect_to hyrax_image_path(solr_data[:id]) }
    end

    context 'when a Handle exists for a StudentWork' do
      let(:handle) { '10385/9012' }
      let(:solr_data) do
        {
          id: 'existing-student_work',
          has_model_ssim: ['StudentWork'],
          identifier_ssim: ["hdl:#{handle}"]
        }
      end

      it { is_expected.to redirect_to hyrax_student_work_path(solr_data[:id]) }
    end

    context 'when a Handle exists for a Collection' do
      let(:handle) { '10385/9012' }
      let(:solr_data) do
        {
          id: 'existing-col',
          has_model_ssim: ['Collection'],
          identifier_ssim: ["hdl:#{handle}"]
        }
      end

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.collection_path(solr_data[:id]) }
    end

    context 'when a handle does not exist for an item' do
      let(:handle) { '1234/nothere' }

      let(:solr_data) { { id: 'unrelated' } }

      it { is_expected.to have_http_status :not_found }
    end
  end
end
