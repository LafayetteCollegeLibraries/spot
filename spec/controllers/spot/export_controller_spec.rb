# frozen_string_literal: true
require 'fileutils'

RSpec.describe Spot::ExportController do
  routes { Rails.application.routes }

  before { allow(controller).to receive(:render) }

  describe 'GET #show' do
    subject(:get_export!) { get :show, params: { id: item_id, format: :zip } }

    context 'when requesting a file_set' do
      let(:item_id) { FileSet.create.id }

      it { is_expected.to redirect_to Hyrax::Engine.routes.url_helpers.download_path(item_id) }
    end

    context 'when requesting a work' do
      before { allow(controller).to receive(:send_data) }

      after { FileUtils.rm(cached_file) }

      let(:work) { create(:publication) }
      let(:item_id) { work.id }
      let(:cached_file) { Rails.root.join('tmp', 'export', "#{item_id}-#{work.etag[3..-2]}.zip") }

      it 'calls :send_data' do
        get_export!

        expect(controller).to have_received(:send_data)
      end
    end
  end
end
