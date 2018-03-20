include Warden::Test::Helpers

RSpec.feature 'Create a TrusteeDocument', :clean, :js do
  context 'a logged in user' do
    let(:user) { create(:user) }

    before do
      AdminSet.find_or_create_default_admin_set_id
      login_as user
    end

    scenario do
      visit '/dashboard?locale=en'
      click_link "Works"
      click_link "Add new work"

      # If you generate more than one work uncomment these lines
      choose "payload_concern", option: "TrusteeDocument"
      click_button "Create work"

      expect(page).to have_content "Add New Trustee Document"
    end
  end
end
