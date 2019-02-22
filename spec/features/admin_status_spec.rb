# frozen_string_literal: true
RSpec.feature 'the system status dashboard panel' do
  before do
    allow(OkComputer::Registry).to receive(:all).and_return(mock_collection)
    allow(mock_collection).to receive(:run)
    allow(mock_collection).to receive(:collection).and_return(mock_results)

    login_as user
  end

  let(:user) { create(:admin_user) }
  let(:mock_collection) { instance_double('OkComputer::CheckCollection') }
  let(:mock_results) do
    {
      'ok_service' => OkComputer::Check.new.tap do |check|
        check.registrant_name = 'ok_service'
        check.failure_occurred = false
        check.message = 'we are ok here'
      end,

      'urkel_service' => OkComputer::Check.new.tap do |check|
        check.registrant_name = 'urkel_service'
        check.failure_occurred = true
        check.message = 'did i do that?'
      end
    }
  end

  scenario do
    visit '/dashboard'
    click_link 'System Status'

    expect(page).to have_content 'System Status'

    rows = page.find_all('.table tbody tr')

    # the working jawn
    ok_service = rows[0]
    ok_service_td = ok_service.find_all('td')

    expect(ok_service_td[0]).to have_content mock_results['ok_service'].registrant_name
    expect(ok_service_td[1]).to have_css 'span.glyphicon-ok'
    expect(ok_service_td[2]).to have_content mock_results['ok_service'].message

    urkel_service = rows[1]
    urkel_service_td = urkel_service.find_all('td')

    expect(urkel_service_td[0]).to have_content mock_results['urkel_service'].registrant_name
    expect(urkel_service_td[1]).to have_css 'span.glyphicon-remove'
    expect(urkel_service_td[2]).to have_content mock_results['urkel_service'].message
  end
end
