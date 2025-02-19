# frozen_string_literal: true
RSpec.shared_examples 'it includes Spot::WorksControllerBehavior' do
  let(:work_type) { described_class.curation_concern_type.name.underscore }
  let(:using_valkyrie_resource) { work_type.end_with?('_resource') }
  let(:factory_name) { using_valkyrie_resource ? :"#{work_type}_with_required_fields_only" : work_type.to_sym }
  let(:factory_method) { using_valkyrie_resource ? :valkyrie_create : :create }
  let(:visibility_trait) { :public }
  let(:work) { FactoryBot.send(factory_method, factory_name, visibility_trait) }

  describe 'Hyrax::WorksControllerBehavior' do
    # @todo is this class_attribute going anywhere? keep an eye on it, i guess.
    context "when visiting a known #{described_class.curation_concern_type}" do
      before do
        get :show, params: { id: work.id.to_s }
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
      let(:visibility_trait) { :private }

      before do
        get :show, params: { id: work.id.to_s }
      end

      it 'redirects to the login page' do
        expect(response.status).to eq 302
        expect(response.headers['Location']).to include '/users/sign_in'
      end
    end
  end

  describe 'setting workflow_presenter' do
    context 'when editing a work' do
      it 'sets a @workflow_presenter' do
        get :edit, params: { id: work.id.to_s }
        presenter = assigns(:workflow_presenter)

        expect(presenter).not_to be nil
        expect(presenter).to be_a Hyrax::WorkflowPresenter
      end
    end

    context 'when viewing a work' do
      it 'does nothing' do
        get :show, params: { id: work.id.to_s }
        presenter = assigns(:workflow_presenter)

        expect(presenter).to be nil
      end
    end
  end

  describe 'updating flash message' do
    subject(:flash_notice) { response.request.flash[:notice] }

    before do
      allow(Hyrax::CurationConcern.actor).to receive(:update).and_return true
      allow(Hyrax::WorkflowPresenter).to receive(:new).and_return(mock_workflow_presenter)

      sign_in admin_user
    end

    let(:admin_user) { FactoryBot.create(:admin_user) }
    let(:mock_workflow_presenter) { instance_double('Hyrax::WorkflowPresenter', actions: workflow_actions) }
    let(:workflow_actions) { [] }
    let(:response) { put :update, params: { id: work.id.to_s } }

    it 'notifies that the work has been updated' do
      expect(flash_notice).to include('successfully updated')
      expect(flash_notice).not_to include('Finished making edits?')
    end

    context 'when workflow_actions exist' do
      let(:workflow_actions) { [:workflow_action] }

      it 'appends a note to flash[:notice] about the workflow_action form' do
        expect(flash_notice).to include('Finished making edits?')
      end
    end
  end

  describe 'additional formats' do
    context 'when requesting the metadata as csv' do
      let(:disposition)  { response.header.fetch('Content-Disposition') }
      let(:content_type) { response.header.fetch('Content-Type') }
      let(:visibility_trait) { :public }

      it 'downloads the file' do
        get :show, params: { id: work.id.to_s, format: 'csv' }

        expect(response).to be_successful
        expect(disposition).to include 'attachment'
        expect(content_type).to eq 'text/csv'
        expect(response.body).to start_with('id,title')
      end
    end
  end
end
