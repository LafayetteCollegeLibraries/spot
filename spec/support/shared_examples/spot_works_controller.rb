# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::WorksControllerBehavior' do
  let(:work_type) { described_class.name.split('::').last.sub('Controller', '').singularize.downcase.to_sym }
  let(:work) { create(work_type, :public) }

  describe 'Hyrax::WorksControllerBehavior' do
    # @todo is this class_attribute going anywhere? keep an eye on it, i guess.
    context "when visiting a known #{described_class.curation_concern_type}" do
      before do
        get :show, params: { id: work.id }
      end

      it { expect(response).to be_successful }
    end

    context 'when visiting a non-existant publication' do
      it 'raises a Blacklight::RecordNotFound error' do
        expect { get :show, params: { id: 'not-here' } }
          .to raise_error(Blacklight::Exceptions::RecordNotFound)
      end
    end

    context 'when visiting a Private Publication as a guest' do
      let(:doc) { create(:publication, :private) }

      before do
        get :show, params: { id: doc.id }
      end

      it 'redirects to the login page' do
        expect(response.status).to eq 302
        expect(response.headers['Location']).to include '/users/sign_in'
      end
    end
  end

  describe 'additional formats' do
    context 'when requesting the metadata as csv' do
      let(:disposition)  { response.header.fetch('Content-Disposition') }
      let(:content_type) { response.header.fetch('Content-Type') }

      it 'downloads the file' do
        get :show, params: { id: work.id, format: 'csv' }

        expect(response).to be_successful
        expect(disposition).to include 'attachment'
        expect(content_type).to eq 'text/csv'
        expect(response.body).to start_with('id,has_model')
      end
    end
  end
end
