# frozen_string_literal: true
RSpec.feature 'the fixity status dashboard page' do
  before do
    login_as user
  end

  context 'when when the user is an admin' do
    let(:user) { create(:admin_user) }

    scenario do
      visit '/dashboard'

      expect(page).to have_content 'importers'

      click_link 'importers'

      expect(page).to have_content 'No importers have been created.'

      visit '/dashboard'

      expect(page).to have_content 'exporters'

      click_link 'exporters'

      expect(page).to have_content 'No exporters have been created.'
    end
  end

  context 'when when the user is a student' do
    let(:user) { create(:student_user) }

    scenario do
      visit '/dashboard'

      expect(page).not_to have_content 'importers'
      expect(page).not_to have_content 'exporters'
    end
  end
end
