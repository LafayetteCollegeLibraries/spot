# frozen_string_literal: true
RSpec.feature 'Create a Publication', :clean, :js do
  before do
    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.publication') }
  let(:app_name) { I18n.t('hyrax.product_name') }

  context 'a logged in admin user' do
    let(:user) { create(:admin_user) }
    let(:attrs) { attributes_for(:publication, identifier: [id_local.to_s, id_standard.to_s]) }
    let(:id_local) { Spot::Identifier.new('local', 'abc123') }
    let(:id_standard) { Spot::Identifier.new('issn', '1234-5678') }
    let(:identifier) { Spot::Identifier.from_string(attrs[:identifier].first) }

    describe 'can fill out and submit a new Publication' do
      scenario do
        visit '/dashboard'
        click_link 'Works'
        click_link 'Add new work'

        sleep 1

        choose 'Publication'
        click_button 'Create work'

        expect(page).to have_content "Add New #{i18n_term}"

        fill_in 'publication_title', with: attrs[:title].first
        expect(page).not_to have_css '.publication_title .controls-add-text'

        fill_in 'publication_rights_holder', with: attrs[:rights_holder].first
        expect(page).to have_css '.publication_rights_holder .controls-add-text'

        fill_in 'publication_subtitle', with: attrs[:subtitle].first
        expect(page).to have_css '.publication_subtitle .controls-add-text'

        fill_in 'publication_title_alternative', with: attrs[:title_alternative].first
        expect(page).to have_css '.publication_title_alternative .controls-add-text'

        fill_in 'publication_publisher', with: attrs[:publisher].first
        expect(page).to have_css '.publication_publisher .controls-add-text'

        fill_in 'publication_source', with: attrs[:source].first
        expect(page).to have_css '.publication_source .controls-add-text'

        select 'Article', from: 'publication_resource_type'
        expect(page).not_to have_css '.publication_resource_type .controls-add-text'

        fill_in_autocomplete '.publication_language', with: attrs[:language].first
        expect(page).to have_css '.publication_language .controls-add-text'

        fill_in 'publication_abstract', with: attrs[:abstract].first
        expect(page).not_to have_css '.publication_abstract .controls-add-text'

        fill_in 'publication_description', with: attrs[:description].first
        expect(page).to have_css '.publication_description .controls-add-text'

        select id_standard.prefix_label, from: 'publication[standard_identifier_prefix][]'
        fill_in 'publication[standard_identifier_value][]', with: id_standard.value

        fill_in 'publication[local_identifier][]', with: id_local.to_s

        fill_in 'publication_bibliographic_citation', with: attrs[:bibliographic_citation].first
        expect(page).to have_css '.publication_bibliographic_citation .controls-add-text'

        fill_in 'publication_date_issued', with: attrs[:date_issued].first
        expect(page).not_to have_css '.publication_date_issued .controls-add-text'

        fill_in 'publication_creator', with: attrs[:creator].first
        expect(page).to have_css '.publication_creator .controls-add-text'

        fill_in 'publication_contributor', with: attrs[:contributor].first
        expect(page).to have_css '.publication_contributor .controls-add-text'

        fill_in 'publication_editor', with: attrs[:editor].first
        expect(page).to have_css '.publication_editor .controls-add-text'

        fill_in_autocomplete '.publication_academic_department',
                             with: attrs[:academic_department].first
        expect(page).to have_css '.publication_academic_department .controls-add-text'

        fill_in_autocomplete '.publication_division', with: attrs[:division].first
        expect(page).to have_css '.publication_division .controls-add-text'

        fill_in_autocomplete '.publication_subject', with: attrs[:subject].first
        expect(page).to have_css '.publication_subject .controls-add-text'

        fill_in 'publication_organization', with: attrs[:organization].first
        expect(page).to have_css '.publication_organization .controls-add-text'

        fill_in 'publication_keyword', with: attrs[:keyword].first
        expect(page).to have_css '.publication_keyword .controls-add-text'

        select 'No Known Copyright', from: 'publication_rights_statement'

        ##
        # add files
        ##

        # not entirely sure _why_ this is happening, but upgrading chrome
        # from 73 -> 74 was raising the error:
        #
        #   Failure/Error: click_link 'Files'
        #
        #     Selenium::WebDriver::Error::WebDriverError:
        #       element click intercepted: Element <a href="#files" aria-controls="files" role="tab" data-toggle="tab">...</a>
        #       is not clickable at point (423, 21). Other element would receive the click:
        #       <input type="text" name="q" id="search-field-header" class="form-control" placeholder="Begin your search here">
        #         (Session info: headless chrome=74.0.3729.108)
        #         (Driver info: chromedriver=74.0.3729.6 (255758eccf3d244491b8a1317aa76e1ce10d57e9-refs/branch-heads/3729@{#29}),platform=Mac OS X 10.12.6 x86_64)
        #
        # from the best that I can tell, what's happening is that we're far-enough down
        # the screen that the +a[href="#files"]+ tab is out of view and not clickable?
        # in a byebug console, trying +click_link 'Files'+ once will raise the error,
        # but then repeating the +click_link+ call will succeed, leading me to believe
        # that the page is scrolling up as a reset?
        #
        # again, no idea _why_ it's happening, but scrolling to the top of the page
        # seems to stop the problem. so we'll go with it for now.
        page.execute_script('window.scrollTo(0,0)')

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
        expect(page).to have_content "Your files are being processed by #{app_name} in the background."
      end
    end
  end
end
