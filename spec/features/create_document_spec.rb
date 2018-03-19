# Generated via
#  `rails generate hyrax:work Document`
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a Document', js: true do
  context 'a logged in user' do
    let(:user) { create(:user) }

    before do
      AdminSet.find_or_create_default_admin_set_id
      login_as user
    end

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      # choose "payload_concern", option: "Document"
      # click_button "Create work"

      expect(page).to have_content "Add New Document"
    end
  end
end
