RSpec.feature 'Create a Publication', :clean, :js do
  before do
    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.publication') }

  context 'a logged in (regular) user' do
    let(:user) { create(:user) }
    let(:attrs) { attributes_for(:publication) }

    describe 'should be taken directly to the new Publication form' do
      scenario do
        visit '/dashboard?locale=en'
        click_link 'Works'
        click_link 'Add new work'

        # TODO: until we have more than one option for (non admin/trustee) users
        # to choose from, when 'Add new work' is clicked, it'll just lead to the
        # Publication form.

        expect(page).to have_content "Add New #{i18n_term}"

        ##
        # fill in required fields
        ##

        fill_in 'Title', with: attrs[:title].first
        expect(page).to have_css '.publication_title .controls-add-text'

        fill_in 'Date Created', with: attrs[:date_created].first
        expect(page).not_to have_css '.publication_date_created .controls-add-text'

        fill_in 'Issued', with: attrs[:issued].first
        expect(page).not_to have_css '.publication_issued .controls-add-text'

        fill_in 'Available', with: attrs[:available].first
        expect(page).not_to have_css '.publication_available .controls-add-text'

        select 'No Known Copyright', from: 'Rights statement'

        ##
        # fill in optional fields
        ##

        click_link 'Additional fields'

        fill_in 'Creator', with: attrs[:creator].first
        expect(page).to have_css '.publication_creator .controls-add-text'

        fill_in 'Contributor', with: attrs[:contributor].first
        expect(page).to have_css '.publication_contributor .controls-add-text'

        fill_in 'Publisher', with: attrs[:publisher].first
        expect(page).to have_css '.publication_publisher .controls-add-text'

        fill_in 'Source', with: attrs[:source].first
        expect(page).to have_css '.publication_source .controls-add-text'

        select 'Article', from: 'Resource type'

        fill_in 'Language', with: attrs[:language].first
        expect(page).to have_css '.publication_language .controls-add-text'

        fill_in 'Abstract', with: attrs[:abstract].first
        expect(page).not_to have_css '.publication_abstract .controls-add-text'

        fill_in 'Description', with: attrs[:description].first
        expect(page).to have_css '.publication_description .controls-add-text'

        fill_in 'Identifier', with: attrs[:identifier].first
        expect(page).to have_css '.publication_identifier .controls-add-text'

        fill_in 'Academic department', with: attrs[:academic_department].first
        expect(page).to have_css '.publication_academic_department .controls-add-text'

        fill_in 'Division', with: attrs[:division].first
        expect(page).to have_css '.publication_division .controls-add-text'

        fill_in 'Organization', with: attrs[:organization].first
        expect(page).to have_css '.publication_organization .controls-add-text'

        ##
        # add files
        ##

        click_link 'Files'

        expect(page).to have_content 'Add files'

        within('span#addfiles') do
          attach_file('files[]', "#{::Rails.root}/spec/fixtures/document.pdf", visible: false)
        end

        ##
        # select visibility
        ##

        choose 'publication_visibility_open'

        ##
        # check the agreement
        ##

        check 'agreement'

        click_on 'Save'

        expect(page).to have_content attrs[:title].first
        expect(page).to have_content 'Your files are being processed by Spot in the background.'
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
