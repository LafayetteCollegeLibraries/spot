# frozen_string_literal: true
RSpec.describe Hyrax::StudentWorksController do
  it_behaves_like 'it includes Spot::WorksControllerBehavior'

  describe 'viewing a work-in-progress' do
    let(:solr_doc) do
      {
        'id' => 'abc123def',
        'has_model_ssim' => ['StudentWork'],
        'title_tesim' => ['Title of Work'],
        'advisor_ssim' => [advisor.user_key],
        'depositor_ssim' => [depositor.user_key],
        'visibility_ssi' => 'public',
        'workflow_state_name_ssim' => 'advisor_requests_changes',
        'read_access_person_ssim' => [depositor.user_key, advisor.user_key],
        'edit_access_person_ssim' => [depositor.user_key],
        'suppressed_bsi' => true
      }
    end

    let(:advisor) { FactoryBot.create(:user) }
    let(:depositor) { FactoryBot.create(:user) }
    let(:current_user) { nil }

    before do
      ActiveFedora::SolrService.add(solr_doc, commit: true)

      sign_in(current_user) unless current_user.nil?
    end

    after do
      ActiveFedora::SolrService.instance.conn.delete_by_query("id:#{solr_doc['id']}", commit: true)
    end

    context 'when the current_user is a general one' do
      it 'redirects the user to log in' do
        get :show, params: { id: solr_doc['id'] }

        expect(response.code).to eq('302')
      end
    end

    context 'when the current_user has no relation to the work' do
      let(:current_user) { FactoryBot.create(:user) }

      it 'renders 401 Unauthorized' do
        get :show, params: { id: solr_doc['id'] }

        expect(response.code).to eq('401')
      end
    end

    context 'when the current_user is the depositor' do
      let(:current_user) { depositor }

      it 'displays the work' do
        get :show, params: { id: solr_doc['id'] }

        expect(response).to be_ok
      end
    end

    context 'when the current_user is the advisor' do
      let(:current_user) { advisor }

      before do
        allow(Hyrax::Workflow::PermissionQuery)
          .to receive(:scope_permitted_workflow_actions_available_for_current_state)
          .and_return([])
      end

      it 'displays the work' do
        get :show, params: { id: solr_doc['id'] }

        expect(response).to be_ok
      end
    end
  end
end
