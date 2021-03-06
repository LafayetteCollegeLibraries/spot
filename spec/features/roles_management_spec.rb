# frozen_string_literal: true
RSpec.feature 'Role management' do
  before do
    login_as user
  end

  let(:user) { create(:admin_user) }
  let(:role_name) { 'cool-new-role' }

  describe 'adding/deleting a role' do
    scenario do
      visit '/admin/roles/new'

      fill_in 'Role name', with: role_name
      page.find('[name="commit"]').click

      expect(page).to have_content 'Role was successfully created.'
      expect(page).to have_content "Editing role: #{role_name}"

      click_button 'Delete Role'

      expect(page).to have_content 'Role was successfully deleted.'
      expect(Role.find_by(name: role_name)).to be nil
    end
  end

  describe "editing a role's users" do
    let(:user) { create(:admin_user, email: email) }
    let(:email) { 'cool-librarian@lafayette.edu' }
    let(:role) { Role.find_or_create_by(name: role_name) }

    scenario do
      visit "/admin/roles/#{role.id}/edit"

      expect(page).not_to have_css 'table#users'

      fill_in 'user_key', with: email
      click_button 'Add User'

      expect(page).to have_css 'table#users'

      click_button 'Remove User'

      expect(page).not_to have_css 'table#users'
    end
  end

  describe 'adding a non-existing user to a role' do
    let(:role) { Role.find_or_create_by(name: role_name) }
    let(:new_user_email) { 'new-user@lafayette.edu' }

    scenario do
      visit "/admin/roles/#{role.id}/edit"

      fill_in 'user_key', with: new_user_email
      click_button 'Add User'

      expect(User.find_by(email: new_user_email)).not_to be_nil

      expect(page).to have_css 'div.alert.alert-info'
      expect(page.find('table#users')).to have_content new_user_email
    end
  end
end
