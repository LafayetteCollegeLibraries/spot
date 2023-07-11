# frozen_string_literal: true
RSpec.feature 'the fixity status dashboard page' do
  before do
    login_as user
  end

  let(:user) { create(:admin_user) }

  context 'when no fixity errors are found' do
    scenario do
      visit '/admin/fixity_checks'

      expect(page).to have_content 'Fixity Checks'
      expect(page).to have_content 'The most recent round of fixity checks found 0 errors.'
    end
  end

  context 'when fixity errors are found' do
    before do
      ChecksumAuditLog.find_or_create_by(
        file_set_id: file_set_id,
        expected_result: expected_result,
        updated_at: updated_at,
        created_at: updated_at,
        passed: false
      )
    end

    let(:updated_at) { Time.now.utc }
    let(:file_set_id) { 'abc123' }
    let(:expected_result) { 'lololololol' }

    scenario do
      visit '/admin/fixity_checks'

      expect(page).to have_content 'Fixity Checks'
      expect(page).to have_content 'The most recent round of fixity checks found 1 error.'

      expect(page).to have_content file_set_id
      expect(page).to have_content updated_at
      expect(page).to have_content expected_result
    end
  end
end
