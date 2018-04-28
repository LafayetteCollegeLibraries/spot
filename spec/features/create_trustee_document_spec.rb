RSpec.feature 'Create a TrusteeDocument', :clean, :js do
  before do
    AdminSet.find_or_create_default_admin_set_id
    login_as user

    # There is no fits installed on travis-ci
    allow(CharacterizeJob).to receive(:perform_later)
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.trustee_document') }

  context 'an admin user' do
    let(:user) { create(:admin_user) }
    let(:attrs) { attributes_for(:trustee_document) }

    describe 'can create a Trustee Document' do
      scenario do
        visit '/concern/trustee_documents/new'
        expect(page).to have_content "Add New #{i18n_term}"

        click_link 'Files'
        within '#addfiles' do
          attach_file 'files[]',
                      "#{Rails.root}/spec/fixtures/image-document.pdf",
                      visible: false,
                      wait: 10
        end

        click_link 'Description'
        fill_in 'Title', with: attrs[:title].first
        fill_in 'Date Created', with: attrs[:date_created].first
        fill_in 'Source', with: attrs[:source].first

        click_link 'Additional fields'

        fill_in 'Page start', with: attrs[:page_start]
        fill_in 'Page end', with: attrs[:page_end]

        # TODO: for some reason, we're not able to have a TrusteeDocument's
        # visibility set to 'Public' (or, rather 'open')
        #
        # choose 'trustee_document[visibility]', option: 'open'

        check 'agreement'

        # chill out + give js a chance to do its thing
        sleep(2)
        expect(find('#with_files_submit')).not_to be_disabled

        click_on 'Save'

        # give Spot a chance to process the document (but not characterize
        # the document)
        doc = TrusteeDocument.where(title: attrs[:title]).first while doc.nil?

        expect(page).to have_content doc.title.first
        expect(page).to have_content doc.date_created.first
        expect(page).to have_content doc.source.first

        # these need to be configured within the catalog_controller.rb first
        # expect(page).to have_content doc.page_start
        # expect(page).to have_content doc.page_end
      end
    end
  end

  context 'a logged in (regular) user' do
    let(:user) { create(:user) }

    describe 'should not see an option for TrusteeDocument' do
      scenario do
        visit '/dashboard?locale=en'
        click_link 'Works'
        click_link 'Add new work'

        # If you generate more than one work uncomment these lines
        # choose 'payload_concern', option: 'TrusteeDocument'
        # click_button 'Create work'

        expect(page).not_to have_content "Add New #{i18n_term}"
      end
    end

    describe 'should not be able to see Trustee Document form' do
      scenario do
        visit '/concern/trustee_documents/new'
        expect(page).to have_content('You are not authorized to access this page')
      end
    end
  end
end
