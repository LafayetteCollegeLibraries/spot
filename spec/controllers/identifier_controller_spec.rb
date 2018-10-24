# frozen_string_literal: true

RSpec.describe IdentifierController do
  describe '#handle' do
    subject { get :handle, params: { id: handle } }

    context 'when a handle exists for an item' do
      let(:handle) { '1234/5678' }
      let(:work) { build(:publication, identifier: ["hdl:#{handle}"]) }

      before { work.save }

      it { is_expected.to redirect_to hyrax_publication_path(work.id) }
    end

    context 'when a handle does not exist for an item' do
      let(:handle) { 'not/here' }

      it { is_expected.to have_http_status :not_found }
    end
  end
end
