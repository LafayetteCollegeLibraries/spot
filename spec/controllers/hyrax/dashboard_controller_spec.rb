# frozen_string_literal: true
RSpec.describe Hyrax::DashboardController do
  routes { Hyrax::Engine.routes }

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
        expect(response).to render_template('show_user')
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
