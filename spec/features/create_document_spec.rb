RSpec.feature 'Create a Document', :clean, :js do
  before do
    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  context 'a logged in (regular) user' do
    let(:user) { create(:user) }
    
    describe 'should be taken directly to the new Document form' do
      scenario do
        visit '/dashboard?locale=en'
        click_link 'Works'
        click_link 'Add new work'

        # TODO: until we have more than one option for (non admin/trustee) users
        # to choose from, when 'Add new work' is clicked, it'll just lead to the
        # Document form. when the time comes, the following test should work(?)
        #
        # expect(page).not_to have_css('input[value="TrusteeDocument"]')

        expect(page).to have_content "Add New Document"
      end
    end
  end

  context 'an admin user' do
    let(:user) { create(:admin_user) }

    describe 'should be presented with multiple options' do
      scenario do
        visit '/dashboard?locale=en'
        click_link "Works"
        click_link "Add new work"

        # If you generate more than one work uncomment these lines
        choose "payload_concern", option: "Document"
        click_button "Create work"

        expect(page).to have_content "Add New Document"
      end
    end
  end
end
