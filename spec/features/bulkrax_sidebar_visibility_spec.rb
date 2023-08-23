# frozen_string_literal: true
RSpec.feature 'the bulkrax importers and exporters dashboard page' do
  before do
    login_as user
  end

  context 'when when the user is an admin' do
    let(:user) { create(:admin_user) }

    scenario do
      visit '/dashboard'

      expect(page).to have_content 'Importers'

      click_link 'Importers'

      expect(page).to have_content 'No importers have been created.'

      # visit '/dashboard'

      # expect(page).to have_content 'Exporters'

      # click_link 'Exporters'

      # expect(page).to have_content 'No exporters have been created.'
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
