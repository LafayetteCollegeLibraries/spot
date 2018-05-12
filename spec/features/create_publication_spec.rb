RSpec.feature 'Create a Publication', :clean, :js do
  before do
    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.publication') }

  context 'a logged in (regular) user' do
    let(:user) { create(:user) }

    describe 'should be taken directly to the new Publication form' do
      scenario do
        visit '/dashboard?locale=en'
        click_link 'Works'
        click_link 'Add new work'

        # TODO: until we have more than one option for (non admin/trustee) users
        # to choose from, when 'Add new work' is clicked, it'll just lead to the
        # Publication form.

        expect(page).to have_content "Add New #{i18n_term}"
      end
    end
  end

  context 'an admin user' do
    let(:user) { create(:admin_user) }

    describe 'should be presented with multiple options' do
      scenario do
        pending 'will return to when more work types are defined'

        visit '/dashboard?locale=en'
        click_link "Works"
        click_link "Add new work"

        # we're moving too fast for js
        sleep(1)

        expect(page.find_all('input[name="payload_concern"]').length).to be > 1

        choose "payload_concern", option: "Publication"
        click_button "Create work"

        expect(page).to have_content "Add New #{i18n_term}"
      end
    end
  end
end
