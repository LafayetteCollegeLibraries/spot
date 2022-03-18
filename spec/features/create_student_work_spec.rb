# frozen_string_literal: true
RSpec.feature 'Create a StudentWork', :clean, :js do
  before do
    stub_request(:get, subject_uri)

    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t('activefedora.models.student_work') }
  let(:app_name) { I18n.t('hyrax.product_name') }
  let(:attrs) { attributes_for(:student_work, subject: [subject_uri]) }
  let(:standard_id) { Spot::Identifier.new('issn', '1234-5678') }
  let(:subject_uri) { 'http://id.worldcat.org/fast/895423' }

  context 'an admin user' do
    let(:user) { create(:admin_user) }

    scenario 'can fill out and submit a new StudentWork' do
      visit '/dashboard'

      click_link 'Works'
      sleep 1
      click_link 'Add new work'

      sleep 1

      choose 'Student Work'
      click_button 'Create work'

      expect(page).to have_content "Add New #{i18n_term}"

      fill_in 'student_work_title', with: attrs[:title].first
      expect(page).not_to have_css '.student_work_title .controls-add-text'

      fill_in 'student_work_creator', with: attrs[:creator].first
      expect(page).to have_css '.student_work_creator .controls-add-text'

      fill_in_autocomplete '.student_work_advisor', with: attrs[:advisor].first
      expect(page).to have_css '.student_work_advisor .controls-add-text'

      fill_in_autocomplete '.student_work_academic_department', with: 'Libraries'
      expect(page).to have_css '.student_work_academic_department .controls-add-text'

      fill_in 'student_work_description', with: attrs[:description].first
      expect(page).not_to have_css '.student_work_description .controls-add-text'

      fill_in 'student_work_date', with: attrs[:date].first
      expect(page).not_to have_css '.student_work_date .controls-add-text'


      select 'No Copyright - United States', from: 'student_work_rights_statement'
      expect(page).not_to have_css '.student_work_rights_statement .controls-add-text'

      select 'Research Paper', from: 'student_work_resource_type'
      # resource_type's form field allows for multiple values from within
      # a single gui widget, so we should not expect a button to add another value field
      expect(page).not_to have_css '.student_work_resource_type .controls-add-text'

      click_link 'Additional fields'
      sleep 1

      fill_in_autocomplete '.student_work_division', with: 'Humanities'
      expect(page).to have_css '.student_work_division .controls-add-text'

      # @todo we might be removing this field altogether and stuffing it as part of the workflow
      fill_in 'student_work_date_available', with: attrs[:date_available].first
      expect(page).not_to have_css '.student_work_date_available .controls-add-text'

      fill_in 'student_work_abstract', with: attrs[:abstract].first
      expect(page).not_to have_css '.student_work_abstract .controls-add-text'

      fill_in_autocomplete '.student_work_language', with: attrs[:language].first
      expect(page).to have_css '.student_work_language .controls-add-text'

      fill_in 'student_work_related_resource', with: attrs[:related_resource].first
      expect(page).to have_css '.student_work_related_resource .controls-add-text'

      fill_in 'student_work_access_note', with: attrs[:access_note].first
      expect(page).to have_css '.student_work_access_note .controls-add-text'

      fill_in 'student_work_organization', with: attrs[:organization].first
      expect(page).to have_css '.student_work_organization .controls-add-text'

      fill_in_autocomplete '.student_work_subject', with: attrs[:subject].first
      expect(page).to have_css '.student_work_subject .controls-add-text'

      fill_in 'student_work_keyword', with: attrs[:keyword].first
      expect(page).to have_css '.student_work_keyword .controls-add-text'

      fill_in 'student_work_bibliographic_citation', with: attrs[:bibliographic_citation].first
      expect(page).to have_css '.student_work_bibliographic_citation .controls-add-text'

      select standard_id.prefix_label, from: 'student_work[standard_identifier_prefix][]'
      fill_in 'student_work[standard_identifier_value][]', with: standard_id.value

      fill_in 'student_work_note', with: attrs[:note].first
      expect(page).to have_css '.student_work_note .controls-add-text'

      # see long note in +create_publication_spec.rb+ for why we need to scroll back to the top
      page.execute_script('window.scrollTo(0,0)')

      click_link 'Files'
      expect(page).to have_content 'Add files'

      within('span#addfiles') do
        attach_file('files[]', "#{::Rails.root}/spec/fixtures/document.pdf", visible: false)
      end

      # select visibility
      choose 'student_work_visibility_open'

      # check the submission agreement
      # check 'agreement'
      sleep 2

      page.find('#agreement').set(true)

      # give javascript a chance to catch up (otherwise the save button is hidden)
      sleep 2

      page.find('#with_files_submit').click

      expect(page).to have_content attrs[:title].first
      expect(page).to have_content "Your files are being processed by #{app_name} in the background."
      expect(page).to have_content attrs[:academic_department].first
    end
  end
end
