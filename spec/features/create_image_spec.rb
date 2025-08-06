# frozen_string_literal: true
RSpec.feature 'Create an Image', :js, :clean do
  let(:i18n_term) { I18n.t(:'activefedora.models.image') }
  let(:app_name) { I18n.t('hyrax.product_name') }
  let(:subject_uri) { 'http://id.worldcat.org/fast/1061714' }
  let(:attrs) { attributes_for(:image, subject: [subject_uri]) } # should this be a :image_resource?
  let(:admin_user) { create(:admin_user) }
  let(:public_user) { create(:user) }

  before do
    stub_request(:get, subject_uri)
    stub_request(:get, /fast\.oclc\.org\/fastsuggest/)

    ensure_deposit_access_for(admin_user)

    allow(CharacterizeJob).to receive(:perform_later)
  end

  describe 'the create_image page' do
    context 'as an admin user' do
      let(:user) { admin_user }

      scenario 'provides a form to edit' do
        sign_in user

        visit '/concern/images/new'

        expect(page).to have_content "Add New #{i18n_term}"

        fill_in image_selector_for('title'), with: attrs[:title].first
        expect(page).not_to have_css ".#{image_selector_for('title')} .controls-add-text"

        select 'Image', from: image_selector_for('resource_type')
        expect(page).not_to have_css ".#{image_selector_for('resource_type')} .controls-add-text"

        fill_in image_selector_for('date'), with: attrs[:date].first
        expect(page).to have_css ".#{image_selector_for('date')} .controls-add-text"

        select 'Copyright Undetermined', from: image_selector_for('rights_statement')
        expect(page).not_to have_css ".#{image_selector_for('rights_statement')} .controls-add-text"

        fill_in image_selector_for('title_alternative'), with: attrs[:title_alternative].first
        fill_in image_selector_for('title_alternative_language'), with: 'en'
        expect(page).to have_css ".#{image_selector_for('title_alternative')} .controls-add-text"

        fill_in image_selector_for('subtitle'), with: attrs[:subtitle].first
        fill_in image_selector_for('subtitle_language'), with: 'en'
        expect(page).to have_css ".#{image_selector_for('title_alternative')} .controls-add-text"

        fill_in image_selector_for('date_associated'), with: attrs[:date_associated].first
        expect(page).to have_css ".#{image_selector_for('date_associated')} .controls-add-text"

        fill_in image_selector_for('date_scope_note'), with: attrs[:date_scope_note].first
        expect(page).to have_css ".#{image_selector_for('date_scope_note')} .controls-add-text"

        fill_in image_selector_for('rights_holder'), with: attrs[:rights_holder].first
        expect(page).to have_css ".#{image_selector_for('rights_holder')} .controls-add-text"

        fill_in image_selector_for('description'), with: attrs[:description].first
        fill_in image_selector_for('description_language'), with: 'en'
        expect(page).to have_css ".#{image_selector_for('description')} .controls-add-text"

        fill_in image_selector_for('inscription'), with: attrs[:inscription].first
        fill_in image_selector_for('inscription_language'), with: 'en'
        expect(page).to have_css ".#{image_selector_for('inscription')} .controls-add-text"

        fill_in image_selector_for('creator'), with: attrs[:creator].first
        expect(page).to have_css ".#{image_selector_for('creator')} .controls-add-text"

        fill_in image_selector_for('publisher'), with: attrs[:publisher].first
        expect(page).to have_css ".#{image_selector_for('publisher')} .controls-add-text"

        fill_in image_selector_for('keyword'), with: attrs[:keyword].first
        expect(page).to have_css ".#{image_selector_for('keyword')} .controls-add-text"

        fill_in_autocomplete '.image_subject', with: attrs[:subject].first
        expect(page).to have_css(".#{image_selector_for('subject')}.form-control[data-autocomplete='subject']", visible: false)
        expect(page).to have_css(".#{image_selector_for('subject')}.form-control[data-autocomplete-url='/authorities/search/assign_fast/all']", visible: false)
        expect(page).to have_css(".#{image_selector_for('subject')} .controls-add-text")

        # multi-authority for location
        location_selector = "input.#{image_selector_for('location')}.multi_auth_controlled_vocabulary"
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

        expect(page).to have_css(".#{image_selector_for('location')} .controls-add-text")
        # end location

        fill_in_autocomplete ".#{image_selector_for('language')}", with: attrs[:language].first
        expect(page).to have_css(".#{image_selector_for('language')} .controls-add-text")

        fill_in image_selector_for('source'), with: attrs[:source].first
        expect(page).to have_css(".#{image_selector_for('source')} .controls-add-text")

        fill_in image_selector_for('physical_medium'), with: attrs[:physical_medium].first
        expect(page).to have_css(".#{image_selector_for('physical_medium')} .controls-add-text")

        fill_in image_selector_for('original_item_extent'), with: attrs[:original_item_extent].first
        expect(page).to have_css(".#{image_selector_for('original_item_extent')} .controls-add-text")

        fill_in image_selector_for('repository_location'), with: attrs[:repository_location].first
        expect(page).to have_css(".#{image_selector_for('repository_location')} .controls-add-text")

        fill_in image_selector_for('requested_by'), with: attrs[:requested_by].first
        expect(page).to have_css(".#{image_selector_for('requested_by')} .controls-add-text")

        fill_in image_selector_for('research_assistance'), with: attrs[:research_assistance].first
        expect(page).to have_css(".#{image_selector_for('research_assistance')} .controls-add-text")

        fill_in image_selector_for('donor'), with: attrs[:donor].first
        expect(page).to have_css(".#{image_selector_for('donor')} .controls-add-text")

        fill_in image_selector_for('related_resource'), with: attrs[:related_resource].first
        expect(page).to have_css(".#{image_selector_for('related_resource')} .controls-add-text")

        fill_in image_selector_for('local_identifier'), with: 'local:abc123'
        expect(page).to have_css(".#{image_selector_for('local_identifier')} .controls-add-text")

        fill_in_autocomplete ".#{image_selector_for('subject_ocm')}", with: attrs[:subject_ocm].first
        expect(page).to have_css(".#{image_selector_for('subject_ocm')} .controls-add-text")

        fill_in image_selector_for('note'), with: attrs[:note].first
        expect(page).to have_css(".#{image_selector_for('note')} .controls-add-text")

        # see long note in +create_publication_spec.rb+ for why we need to scroll back to the top
        page.execute_script('window.scrollTo(0,0)')

        click_link 'Files'
        expect(page).to have_content 'Add files'

        within('#add-files') do
          attach_file('files[]', "#{::Rails.root}/spec/fixtures/document.pdf", visible: false)
        end

        # select visibility
        choose image_selector_for('visibility_open')

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
