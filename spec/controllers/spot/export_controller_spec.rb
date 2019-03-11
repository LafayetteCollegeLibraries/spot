# frozen_string_literal: true
RSpec.describe Spot::ExportController do
  routes { Rails.application.routes }

  before do
    allow(controller).to receive(:search_results).and_return([nil, [solr_document]])
    allow(Spot::Exporters::ZippedWorkExporter).to receive(:new).and_return(exporter)
    allow(controller.hyrax)
      .to receive(:download_path)
      .with(file_set.id, locale: nil)
      .and_return("/downloads/#{file_set.id}")
  end

  let(:exporter) { instance_double(Spot::Exporters::ZippedWorkExporter, export!: true) }
  let(:work) { instance_double(Publication, id: 'pub000') }
  let(:file_set) { instance_double(FileSet, id: 'fs000') }
  let(:params) { { id: item_id, format: :zip } }
  let(:solr_document) do
    SolrDocument.new id: 'pub000',
                     file_set_ids_ssim: [file_set.id],
                     has_model_ssim: ['Publication'],
                     _version_: '1234567890'
  end

  describe 'GET #show' do
    before do
      allow(controller).to receive(:send_file)
      get :show, params: params
    end

    context 'when requesting a file_set' do
      let(:item_id) { file_set.id }
      let(:solr_document) { SolrDocument.new id: 'fs000', has_model_ssim: ['FileSet'] }

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.download_path(item_id) }
    end

    context 'when requesting the files of a work that only has one' do
      let(:item_id) { work.id }
      let(:params) { { id: item_id, format: :zip, export_type: :files } }

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.download_path(file_set.id) }
    end

    context 'when requesting a work' do
      let(:item_id) { work.id }

      it 'calls :send_data' do
        expect(controller).to have_received(:send_file)
      end
    end
  end
end
