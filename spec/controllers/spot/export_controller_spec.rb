# frozen_string_literal: true
RSpec.describe Spot::ExportController do
  routes { Rails.application.routes }

  before do
    allow(Spot::Exporters::ZippedWorkExporter).to receive(:new).and_return(exporter)
    allow(controller).to receive(:search_results).and_return([nil, doc_list])
    allow(controller).to receive(:send_file)
    allow(controller.hyrax)
      .to receive(:download_path)
      .with(file_set.id)
      .and_return("/downloads/#{file_set.id}")
  end

  let(:exporter) { instance_double(Spot::Exporters::ZippedWorkExporter, export!: true) }
  let(:work) { instance_double(Publication, id: 'pub000') }
  let(:file_set) { instance_double(FileSet, id: 'fs000') }
  let(:doc_list) { [solr_document] }

  describe 'GET #show' do
    let(:params) { { id: item_id } }

    context 'when requesting a file_set' do
      before { get :show, params: params }

      let(:item_id) { file_set.id }
      let(:solr_document) { SolrDocument.new(id: item_id, has_model_ssim: ['FileSet']) }

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.download_path(item_id) }
    end

    context 'when requesting the files of a work that only has one' do
      before { get :show, params: params }

      let(:solr_document) do
        SolrDocument.new(id: item_id,
                         has_model_ssim: ['Publication'],
                         file_set_ids_ssim: [file_set.id],
                         _version_: 123)
      end

      let(:item_id) { 'abc123' }
      let(:params) { { id: item_id, export_type: :files } }

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.download_path(file_set.id) }
    end

    context 'when requesting a private file' do
      before do
        allow(SolrDocument).to receive(:find).with(item_id).and_return(solr_document)
        allow(controller.current_ability).to receive(:can?).with(:read, solr_document).and_return true

        get :show, params: params
      end

      let(:doc_list) { [] }
      let(:item_id) { work.id }
      let(:solr_document) { SolrDocument.new(id: item_id, read_access_group_ssim: []) }

      it 'redirects to login' do
        expect(response)
          .to redirect_to(Rails.application.routes.url_helpers.new_user_session_path)
      end
    end

    context 'when requesting a work' do
      before { allow(controller).to receive(:send_file) { controller.head :ok } }

      let(:item_id) { work.id }
      let(:solr_document) do
        SolrDocument.new(id: work.id,
                         has_model_ssim: ['Publication'],
                         _version_: 123)
      end

      it 'calls :send_file' do
        get :show, params: params

        expect(controller).to have_received(:send_file)
      end
    end
  end
end
