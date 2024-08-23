# frozen_string_literal: true
RSpec.feature 'Create a Audio Visual', :clean, :js do
  before do
    stub_request(:get, subject_uri)
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

        fill_in 'audio_visual_title', with: attrs[:title].first
        expect(page).not_to have_css '.audio_visual_title .controls-add-text'

        fill_in 'audio_visual_date', with: attrs[:date].first
        expect(page).to have_css '.audio_visual_date .controls-add-text'

        select 'Other', from: 'audio_visual_resource_type'
        expect(page).not_to have_css '.audio_visual_resource_type .controls-add-text'

        fill_in 'audio_visual_premade_derivatives', with: attrs[:premade_derivatives].first
        expect(page).to have_css '.audio_visual_premade_derivatives .controls-add-text'

        select 'No Known Copyright', from: 'audio_visual_rights_statement'

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
