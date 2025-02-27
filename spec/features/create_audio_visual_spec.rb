# frozen_string_literal: true
RSpec.feature 'Create a Audio Visual', :clean, :js do
  before do
    stub_request(:get, subject)
    stub_request(:get, /fast\.oclc\.org\/searchfast\/fastsuggest/)

    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.audio_visual') }
  let(:app_name) { I18n.t('hyrax.product_name') }

  context 'an admin user' do
    let(:user) { create(:admin_user) }
    let(:attrs) { attributes_for(:audio_visual) }

    describe 'can fill out and submit a new Audio Visual' do
      scenario do
        visit '/dashboard'
        click_link 'Works'
        click_link 'Add New Work'

        sleep 1

        choose 'Audio Visual'
        click_button 'Create work'

        expect(page).to have_content "Add New #{i18n_term}"

        fill_in audio_visual_selector_for('title'), with: attrs[:title].first
        expect(page).not_to have_css ".#{audio_visual_selector_for('title')}.controls-add-text"

        select 'Audio', from: 'audio_visual_selector_for('resource_type')
        expect(page).not_to have_css '.audio_visual_selector_for('resource_type').controls-add-text'

        select 'No Known Copyright', from: 'audio_visual_selector_for('rights_statement')

        fill_in 'audio_visual_selector_for('date'), with: attrs[:date].first
        expect(page).to have_css '.audio_visual_selector_for('date').controls-add-text'

        fill_in 'audio_visual_selector_for('title_alternative'), with: attrs[:title_alternative].first
        fill_in 'audio_visual_selector_for('title_alternative_language'), with: 'en'
        expect(page).to have_css '.audio_visual_selector_for('title_alternative').controls-add-text'

        fill_in 'audio_visual_selector_for('subtitle'), with: attrs[:subtitle].first
        fill_in 'audio_visual_selector_for('subtitle_language'), with: 'en'
        expect(page).to have_css '.audio_visual_selector_for('title_alternative').controls-add-text'

        fill_in 'audio_visual_selector_for('date_associated'), with: attrs[:date_associated].first
        expect(page).to have_css '.audio_visual_selector_for('date_associated').controls-add-text'

        fill_in 'audio_visual_selector_for('rights_holder'), with: attrs[:rights_holder].first
        expect(page).to have_css '.audio_visual_selector_for('rights_holder').controls-add-text'

        fill_in 'audio_visual_selector_for('description'), with: attrs[:description].first
        fill_in 'audio_visual_selector_for('description_language'), with: 'en'
        expect(page).to have_css '.audio_visual_selector_for('description').controls-add-text'

        fill_in 'audio_visual_selector_for('inscription'), with: attrs[:inscription].first
        fill_in 'audio_visual_selector_for('inscription_language'), with: 'en'
        expect(page).to have_css '.audio_visual_selector_for('inscription').controls-add-text'

        fill_in 'audio_visual_selector_for('creator'), with: attrs[:creator].first
        expect(page).to have_css '.audio_visual_selector_for('creator').controls-add-text'

        fill_in 'audio_visual_selector_for('contributor'), with: attrs[:contributor].first
        expect(page).to have_css '.audio_visual_selector_for('contributor').controls-add-text'

        fill_in 'audio_visual_selector_for('publisher'), with: attrs[:publisher].first
        expect(page).to have_css '.audio_visual_selector_for('publisher').controls-add-text'

        fill_in 'audio_visual_selector_for('keyword'), with: attrs[:keyword].first
        expect(page).to have_css '.audio_visual_selector_for('keyword').controls-add-text'

        fill_in_autocomplete '.audio_visual_selector_for('subject'), with: attrs[:subject].first
        expect(page).to have_css '.audio_visual_selector_for('subject').controls-add-text'

        # multi-authority for location
        location_selector = 'input.audio_visual_location.multi_auth_controlled_vocabulary'
        expect(page).to have_css("#{location_selector}[data-autocomplete='location']", visible: false)

        # @todo maybe this should be a support thing?
        [
          ['GeoNames', '/authorities/search/geonames'],
          ['Getty Thesaurus of Geo. Names', '/authorities/search/getty/tgn']
        ].each do |(name, autocomplete_url)|
          select name, from: 'audio_visual_location_authority_select_0'
          sleep 1

          data_prop = page.evaluate_script("$('#{location_selector}').data('autocomplete-url');")
          expect(data_prop).to eq autocomplete_url

          sleep 1
        end

        expect(page).to have_css('.audio_visual_location .controls-add-text')
        # end location

        fill_in_autocomplete '.audio_visual_language', with: attrs[:language].first
        expect(page).to have_css('.audio_visual_language .controls-add-text')

        fill_in 'audio_visual_source', with: attrs[:source].first
        expect(page).to have_css('.audio_visual_source .controls-add-text')

        fill_in 'audio_visual_physical_medium', with: attrs[:physical_medium].first
        expect(page).to have_css('.audio_visual_physical_medium .controls-add-text')

        fill_in 'audio_visual_original_item_extent', with: attrs[:original_item_extent].first
        expect(page).to have_css('.audio_visual_original_item_extent .controls-add-text')

        fill_in 'audio_visual_repository_location', with: attrs[:repository_location].first
        expect(page).to have_css('.audio_visual_repository_location .controls-add-text')

        fill_in 'audio_visual_research_assistance', with: attrs[:research_assistance].first
        expect(page).to have_css('.audio_visual_research_assistance .controls-add-text')

        fill_in 'audio_visual_related_resource', with: attrs[:related_resource].first
        expect(page).to have_css('.audio_visual_related_resource .controls-add-text')

        fill_in 'audio_visual_local_identifier', with: 'local:abc123'
        expect(page).to have_css('.audio_visual_local_identifier .controls-add-text')

        fill_in 'audio_visual_note', with: attrs[:note].first
        expect(page).to have_css('.audio_visual_note .controls-add-text')

        fill_in 'audio_visual_provenance', with: attrs[:provenance].first
        expect(page).to have_css '.audio_visual_provenance .controls-add-text'

        fill_in 'audio_visual_barcode', with: attrs[:barcode].first
        expect(page).to have_css '.audio_visual_barcode .controls-add-text'

        # see long note in +create_publication_spec.rb+ for why we need to scroll back to the top
        page.execute_script('window.scrollTo(0,0)')

        ##
        # add files
        ##

        click_link 'Files'
        expect(page).to have_content 'Add files'

        within('#add-files') do
          attach_file('files[]', "#{::Rails.root}/spec/fixtures/sound.wav", visible: false)
        end

        # select visibility
        choose 'audio_visual_visibility_open'

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
