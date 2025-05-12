# frozen_string_literal: true
RSpec.feature 'the bulkrax importers and exporters dashboard page' do
  include_context 'Capybara host'

  before do
    login_as user
  end

  context 'when when the user is an admin' do
    let(:user) { create(:admin_user) }

    scenario do
      visit '/dashboard'

      click_link 'Importers'
      expect(page.find('.main-header h1').text).to eq 'Importers'
      expect(page).to have_css 'table#importers-table'

      visit '/dashboard'

      click_link 'Exporters'
      expect(page.find('.main-header h1').text).to eq 'Exporters'
      expect(page).to have_css 'table#exporters-table'
    end
  end

  context 'when when the user is a student' do
    let(:user) { create(:student_user) }

    scenario do
      visit '/dashboard'

      expect(page).not_to have_content 'Importers'
      expect(page).not_to have_content 'Exporters'
    end
  end
end
