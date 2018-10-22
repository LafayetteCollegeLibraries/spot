RSpec.feature 'Create a Publication', :clean, :js do
  before do
    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.publication') }

  context 'a logged in (regular) user' do
    let(:user) { create(:user) }
    let(:attrs) { attributes_for(:publication) }
    let(:identifier) { Spot::Identifier.from_string(attrs[:identifier].first) }

    # TODO: until we have more than one option for (non admin/trustee) users
    # to choose from, when 'Add new work' is clicked, it'll just lead to the
    # Publication form.
    describe 'should be taken directly to the new Publication form' do
      scenario do
        visit '/dashboard?locale=en'
        click_link 'Works'
        click_link 'Add new work'

        sleep 1

        expect(page).to have_content "Add New #{i18n_term}"

        fill_in 'publication_title', with: attrs[:title].first
        expect(page).to have_css '.publication_title .controls-add-text'

        fill_in 'Subtitle', with: attrs[:subtitle].first
        expect(page).to have_css '.publication_subtitle .controls-add-text'

        fill_in 'publication_title_alternative', with: attrs[:title_alternative].first
        expect(page).to have_css '.publication_title_alternative .controls-add-text'

        fill_in 'Publisher', with: attrs[:publisher].first
        expect(page).to have_css '.publication_publisher .controls-add-text'

        fill_in 'Source', with: attrs[:source].first
        expect(page).to have_css '.publication_source .controls-add-text'

        select 'Article', from: 'Resource type'
        expect(page).not_to have_css '.publication_resource_type .controls-add-text'

        fill_in 'Language', with: attrs[:language].first
        expect(page).to have_css '.publication_language .controls-add-text'

        fill_in 'Abstract', with: attrs[:abstract].first
        expect(page).not_to have_css '.publication_abstract .controls-add-text'

        fill_in 'Description', with: attrs[:description].first
        expect(page).to have_css '.publication_description .controls-add-text'

        select 'Handle', from: 'publication[identifier_prefix][]'
        fill_in 'publication[identifier_value][]', with: identifier.value

        fill_in 'Bibliographic citation', with: attrs[:bibliographic_citation].first
        expect(page).to have_css '.publication_bibliographic_citation .controls-add-text'

        fill_in 'Date issued', with: attrs[:date_issued].first
        expect(page).not_to have_css '.publication_date_issued .controls-add-text'

        fill_in 'Date available', with: attrs[:date_available].first
        expect(page).not_to have_css '.publication_date_available .controls-add-text'

        fill_in 'Creator', with: attrs[:creator].first
        expect(page).to have_css '.publication_creator .controls-add-text'

        fill_in 'Contributor', with: attrs[:contributor].first
        expect(page).to have_css '.publication_contributor .controls-add-text'

        fill_in 'Editor', with: attrs[:editor].first
        expect(page).to have_css '.publication_editor .controls-add-text'

        fill_in 'Academic department', with: attrs[:academic_department].first
        expect(page).to have_css '.publication_academic_department .controls-add-text'

        fill_in 'Division', with: attrs[:division].first
        expect(page).to have_css '.publication_division .controls-add-text'

        fill_in 'Organization', with: attrs[:organization].first
        expect(page).to have_css '.publication_organization .controls-add-text'

        fill_in 'Keyword', with: attrs[:keyword].first
        expect(page).to have_css '.publication_keyword .controls-add-text'

        fill_in 'Subject', with: attrs[:subject].first
        expect(page).to have_css '.publication_subject .controls-add-text'

        select 'No Known Copyright', from: 'Rights statement'

        ##
        # add files
        ##

        click_link 'Files'

        expect(page).to have_content 'Add files'

        within('span#addfiles') do
          attach_file('files[]', "#{::Rails.root}/spec/fixtures/document.pdf", visible: false)
        end

        # select visibility
        choose 'publication_visibility_open'

        # check the submission agreement
        # check 'agreement'
        sleep(2)

        page.find('#agreement').set(true)

        # give javascript a chance to catch up (otherwise the save button is hidden)
        sleep(2)

        page.find('#with_files_submit').click
        expect(page).to have_content attrs[:title].first
        expect(page).to have_content 'Your files are being processed by Spot in the background.'
      end
    end
  end
end
