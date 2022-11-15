# frozen_string_literal: true
RSpec.describe Hyrax::DashboardController do
  routes { Hyrax::Engine.routes }

  # This test will periodically fail because the page now includes a Work Types count
  # statistic that collects SolrDocuments and reduces them to just their "human_readable_type_tesim"
  # property. Our test data doesn't always include that field, so when they're collected
  # via Hyrax::Statistic.work_types, it will try to call ".join" on what it assumes to be
  # an array, but is actually nil. So instead, we'll clear out the SolrDocuments beforehand
  # so that the values it iterates through are empty.
  #
  # @see https://github.com/samvera/hyrax/blob/3.x-stable/app/views/hyrax/dashboard/_work_type_graph.html.erb#L7
  # @see https://github.com/samvera/hyrax/blob/3.x-stable/app/models/hyrax/statistic.rb#L44-L52
  # @see https://github.com/LafayetteCollegeLibraries/spot/issues/968
  before :suite do
    Hyrax::SolrService.instance.conn.delete_by_query('*:*', params: { 'softCommit' => true })
  end

  before do
    sign_in user
    get :show
  end

  describe '#show' do
    context 'when an admin user' do
      let(:user) { create(:admin_user) }

      it 'renders the admin dashboard' do
        expect(response).to render_template('show_admin')
      end
    end

    context 'when a depositor user' do
      let(:user) { create(:depositor_user) }

      it 'renders the user dashboard' do
        expect(response).to render_template('show_user')
      end
    end

    context 'when a faculty user' do
      let(:user) { create(:faculty_user) }

      it 'renders the user dashboard' do
        expect(response).to render_template('show_user')
      end
    end

    context 'when a public user' do
      let(:user) { create(:public_user) }

      it 'redirects to the main page' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when a registered user' do
      let(:user) { create(:registered_user) }

      it 'redirects to the main page' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when a student user' do
      let(:user) { create(:student_user) }

      it 'renders the user dashboard' do
        expect(response).to render_template('show_user')
      end
    end
  end
end
