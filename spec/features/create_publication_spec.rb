# frozen_string_literal: true
RSpec.feature 'Create a Publication', :clean, :js do
  before do
    stub_request(:get, subject_uri)
    stub_request(:get, /fast\.oclc\.org\/fastsuggest/)

    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    AdminSet.find_or_create_default_admin_set_id
    login_as user
  end

  let(:i18n_term) { I18n.t(:'activefedora.models.publication') }
  let(:app_name) { I18n.t('hyrax.product_name') }

  context 'an admin user' do
    let(:user) { create(:admin_user) }
    let(:attrs) { attributes_for(:publication, identifier: [id_local.to_s, id_standard.to_s], subject: [subject_uri]) }
    let(:id_local) { Spot::Identifier.new('local', 'abc123') }
    let(:id_standard) { Spot::Identifier.new('issn', '1234-5678') }
    let(:identifier) { Spot::Identifier.from_string(attrs[:identifier].first) }
    let(:subject_uri) { 'http://id.worldcat.org/fast/1061714' }
    let(:selector_prefix) { Hyrax.config.use_valkyrie? ? 'publication_resource' : 'publication' }

    describe 'can fill out and submit a new Publication' do
      scenario do
        visit '/dashboard'
        click_link 'Works'
        click_link 'Add New Work'

        sleep 1

        choose 'Publication'
        click_button 'Create work'

        expect(page).to have_content "Add New #{i18n_term}"

        # @note a little confusing with all the abstraction re: helpers, but we needed a way
        #       to account for "publication" vs "publication_resource" in the selector name and
        #       i wanted to abstract out the field portion as well. it's important to note which
        #       selectors are being used (#fill_in doesn't use a selector prefix, #have_css is
        #       using css classes). without the helpers this looks like:
        #
        #       fill_in 'publication_resource_title', with: attrs[:title].first
        #       expect(page).not_to have_css '.publication_resource_title" .controls-add-text'

        fill_in publication_selector_for('title'), with: attrs[:title].first
        expect(page).not_to have_css ".#{publication_selector_for('title')} .controls-add-text"

        fill_in publication_selector_for('rights_holder'), with: attrs[:rights_holder].first
        expect(page).to have_css ".#{publication_selector_for('rights_holder')} .controls-add-text"

        fill_in publication_selector_for('subtitle'), with: attrs[:subtitle].first
        expect(page).to have_css ".#{publication_selector_for('subtitle')} .controls-add-text"

        fill_in publication_selector_for('title_alternative'), with: attrs[:title_alternative].first
        expect(page).to have_css ".#{publication_selector_for('title_alternative')} .controls-add-text"

        fill_in publication_selector_for('publisher'), with: attrs[:publisher].first
        expect(page).to have_css ".#{publication_selector_for('publisher')} .controls-add-text"

        fill_in publication_selector_for('source'), with: attrs[:source].first
        expect(page).to have_css ".#{publication_selector_for('source')} .controls-add-text"

        select "Article", from: publication_selector_for('resource_type')
        expect(page).not_to have_css ".#{publication_selector_for('resource_type')} .controls-add-text"

        fill_in_autocomplete ".#{publication_selector_for('language')}", with: attrs[:language].first
        expect(page).to have_css ".#{publication_selector_for('language')} .controls-add-text"

        fill_in publication_selector_for('abstract'), with: attrs[:abstract].first
        expect(page).not_to have_css ".#{publication_selector_for('abstract')} .controls-add-text"

        fill_in publication_selector_for('description'), with: attrs[:description].first
        expect(page).to have_css ".#{publication_selector_for('description')} .controls-add-text"

        select id_standard.prefix_label, from: "#{selector_prefix}[standard_identifier_prefix][]"
        fill_in "#{publication_selector_prefix}[standard_identifier_value][]", with: id_standard.value

        fill_in "#{publication_selector_prefix}[local_identifier][]", with: id_local.to_s

        fill_in publication_selector_for('bibliographic_citation'), with: attrs[:bibliographic_citation].first
        expect(page).to have_css ".#{publication_selector_for('bibliographic_citation')} .controls-add-text"

        fill_in publication_selector_for('date_issued'), with: attrs[:date_issued].first
        expect(page).not_to have_css ".#{publication_selector_for('date_issued')} .controls-add-text"

        fill_in publication_selector_for('creator'), with: attrs[:creator].first
        expect(page).to have_css ".#{publication_selector_for('creator')} .controls-add-text"

        fill_in publication_selector_for('contributor'), with: attrs[:contributor].first
        expect(page).to have_css ".#{publication_selector_for('contributor')} .controls-add-text"

        fill_in publication_selector_for('editor'), with: attrs[:editor].first
        expect(page).to have_css ".#{publication_selector_for('editor')} .controls-add-text"

        fill_in_autocomplete publication_selector_for('academic_department'),
                             with: attrs[:academic_department].first
        expect(page).to have_css ".#{publication_selector_for('academic_department')} .controls-add-text"

        fill_in_autocomplete ".#{publication_selector_for('division')}", with: attrs[:division].first
        expect(page).to have_css ".#{publication_selector_for('division')} .controls-add-text"

        fill_in_autocomplete ".#{publication_selector_for('subject')}", with: attrs[:subject].first
        expect(page).to have_css ".#{publication_selector_for('subject')} .controls-add-text"

        fill_in publication_selector_for('organization'), with: attrs[:organization].first
        expect(page).to have_css ".#{publication_selector_for('organization')} .controls-add-text"

        fill_in publication_selector_for('keyword'), with: attrs[:keyword].first
        expect(page).to have_css ".#{publication_selector_for('keyword')} .controls-add-text"

        select 'No Known Copyright', from: publication_selector_for('rights_statement')

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
          attach_file('files[]', "#{::Rails.root}/spec/fixtures/document.pdf", visible: false)
        end

        # select visibility
        choose publication_selector_for('visibility_open')

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
