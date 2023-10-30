# frozen_string_literal: true

RSpec.feature 'Create an Image', :clean, :js do
  before do
    stub_request(:get, subject_uri)
    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.image') }
  let(:app_name) { I18n.t('hyrax.product_name') }
  let(:subject_uri) { 'http://id.worldcat.org/fast/1061714' }
  let(:attrs) { attributes_for(:image, subject: [subject_uri]) }

  context 'a logged in admin user' do
    let(:user) { create(:admin_user) }
    let(:attrs) { attributes_for(:image) }

    # currently we're hiding the new Image form from the nav menus,
    # the thinking is that Images are likely to be ingested as part of
    # a batch, rather than individually. if that changes, you'll want
    # to uncomment the block below
    describe 'can fill out and submit a new Image' do
      scenario do
        visit '/dashboard'
        click_link 'Works'
        click_link 'Add New Work'

        sleep 1

        choose 'Image'
        click_button 'Create work'

        expect(page).to have_content "Add New #{i18n_term}"

        fill_in 'image_title', with: attrs[:title].first
        expect(page).not_to have_css '.image_title .controls-add-text'

        select 'Image', from: 'image_resource_type'
        expect(page).not_to have_css '.image_resource_type .controls-add-text'

        fill_in 'image_date', with: attrs[:date].first
        expect(page).to have_css '.image_date .controls-add-text'

        select 'Copyright Undetermined', from: 'image_rights_statement'
        expect(page).not_to have_css '.image_rights_statement .controls-add-text'

        fill_in 'image_title_alternative', with: attrs[:title_alternative].first
        fill_in 'image_title_alternative_language', with: 'en'
        expect(page).to have_css '.image_title_alternative .controls-add-text'

        fill_in 'image_subtitle', with: attrs[:subtitle].first
        fill_in 'image_subtitle_language', with: 'en'
        expect(page).to have_css '.image_title_alternative .controls-add-text'

        fill_in 'image_date_associated', with: attrs[:date_associated].first
        expect(page).to have_css '.image_date_associated .controls-add-text'

        fill_in 'image_date_scope_note', with: attrs[:date_scope_note].first
        expect(page).to have_css '.image_date_scope_note .controls-add-text'

        fill_in 'image_rights_holder', with: attrs[:rights_holder].first
        expect(page).to have_css '.image_rights_holder .controls-add-text'

        fill_in 'image_description', with: attrs[:description].first
        fill_in 'image_description_language', with: 'en'
        expect(page).to have_css '.image_description .controls-add-text'

        fill_in 'image_inscription', with: attrs[:inscription].first
        fill_in 'image_inscription_language', with: 'en'
        expect(page).to have_css '.image_inscription .controls-add-text'

        fill_in 'image_creator', with: attrs[:creator].first
        expect(page).to have_css '.image_creator .controls-add-text'

        fill_in 'image_publisher', with: attrs[:publisher].first
        expect(page).to have_css '.image_publisher .controls-add-text'

        fill_in 'image_keyword', with: attrs[:keyword].first
        expect(page).to have_css '.image_keyword .controls-add-text'

        fill_in_autocomplete '.image_subject', with: attrs[:subject].first
        expect(page).to have_css('.image_subject.form-control[data-autocomplete="subject"]', visible: false)
        expect(page).to have_css('.image_subject.form-control[data-autocomplete-url="/authorities/search/linked_data/oclc_fast"]', visible: false)
        expect(page).to have_css('.image_subject .controls-add-text')

        # multi-authority for location
        location_selector = 'input.image_location.multi_auth_controlled_vocabulary'
        expect(page).to have_css("#{location_selector}[data-autocomplete='location']", visible: false)

        # @todo maybe this should be a support thing?
        [
          ['GeoNames', '/authorities/search/geonames'],
          ['Getty Thesaurus of Geo. Names', '/authorities/search/getty/tgn']
        ].each do |(name, autocomplete_url)|
          select name, from: 'image_location_authority_select_0'
          sleep 1

          data_prop = page.evaluate_script("$('#{location_selector}').data('autocomplete-url');")
          expect(data_prop).to eq autocomplete_url

          sleep 1
        end

        expect(page).to have_css('.image_location .controls-add-text')
        # end location

        fill_in_autocomplete '.image_language', with: attrs[:language].first
        expect(page).to have_css('.image_language .controls-add-text')

        fill_in 'image_source', with: attrs[:source].first
        expect(page).to have_css('.image_source .controls-add-text')

        fill_in 'image_physical_medium', with: attrs[:physical_medium].first
        expect(page).to have_css('.image_physical_medium .controls-add-text')

        fill_in 'image_original_item_extent', with: attrs[:original_item_extent].first
        expect(page).to have_css('.image_original_item_extent .controls-add-text')

        fill_in 'image_repository_location', with: attrs[:repository_location].first
        expect(page).to have_css('.image_repository_location .controls-add-text')

        fill_in 'image_requested_by', with: attrs[:requested_by].first
        expect(page).to have_css('.image_requested_by .controls-add-text')

        fill_in 'image_research_assistance', with: attrs[:research_assistance].first
        expect(page).to have_css('.image_research_assistance .controls-add-text')

        fill_in 'image_donor', with: attrs[:donor].first
        expect(page).to have_css('.image_donor .controls-add-text')

        fill_in 'image_related_resource', with: attrs[:related_resource].first
        expect(page).to have_css('.image_related_resource .controls-add-text')

        fill_in 'image_local_identifier', with: 'local:abc123'
        expect(page).to have_css('.image_local_identifier .controls-add-text')

        fill_in_autocomplete '.image_subject_ocm', with: attrs[:subject_ocm].first
        expect(page).to have_css('.image_subject_ocm .controls-add-text')

        fill_in 'image_note', with: attrs[:note].first
        expect(page).to have_css('.image_note .controls-add-text')

        # see long note in +create_publication_spec.rb+ for why we need to scroll back to the top
        page.execute_script('window.scrollTo(0,0)')

        click_link 'Files'
        expect(page).to have_content 'Add files'

        within('#add-files') do
          attach_file('files[]', "#{::Rails.root}/spec/fixtures/document.pdf", visible: false)
        end

        # select visibility
        choose 'image_visibility_open'

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
