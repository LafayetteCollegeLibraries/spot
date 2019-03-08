# frozen_string_literal: true
require 'fileutils'

RSpec.describe Spot::ExportController do
  routes { Rails.application.routes }

  before do
    allow(controller).to receive(:render)
    allow(Spot::Exporters::ZippedWorkExporter).to receive(:new).and_return(exporter)
    allow(File).to receive(:open)
    allow(ActiveFedora::Base).to receive(:find).with('fs000').and_return(file_set)
    allow(ActiveFedora::Base).to receive(:find).with('pub000').and_return(work)
    allow(file_set).to receive(:is_a?).with(FileSet).and_return(true)
    allow(controller.hyrax)
      .to receive(:download_path)
      .with(file_set, locale: nil)
      .and_return("/downloads/#{file_set.id}")
  end

  let(:exporter) { instance_double(Spot::Exporters::ZippedWorkExporter, export!: true) }
  let(:work) { instance_double(Publication, id: 'pub000', etag: 'W/"xxxxxx"') }
  let(:file_set) { instance_double(FileSet, id: 'fs000') }

  describe 'GET #show' do
    before do
      allow(controller).to receive(:send_data)
      get :show, params: { id: item_id, format: :zip }
    end

    context 'when requesting a file_set' do
      let(:item_id) { file_set.id }

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.download_path(item_id) }
    end

    context 'when requesting a work' do
      let(:item_id) { work.id }

      it 'calls :send_data' do
        expect(controller).to have_received(:send_data)
      end
    end
  end
end
