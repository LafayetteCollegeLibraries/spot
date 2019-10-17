# frozen_string_literal: true
RSpec.feature 'Advanced search form', :clean, :js do
  before do
    # add some stuff to the index
  end

  scenario 'the advanced search form' do
    visit '/advanced'

    expect(page).to have_content 'More Search Options'

    # search fields
    expect(page).to have_css 'input[name="all_fields"]'
    expect(page).to have_css 'input[name="title"]'
    expect(page).to have_css 'input[name="author"]'
    expect(page).to have_css 'input[name="full_text"]'
  end
end
