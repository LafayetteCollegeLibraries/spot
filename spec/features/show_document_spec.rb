RSpec.feature 'Show Document page', js: false do
  let(:user) { create(:user) }
  let(:doc) { create(:document, depositor: user.user_key) }

  before do
    pdf_file = "#{::Rails.root}/spec/fixtures/image-document.pdf"
    uploaded_files = [
      Hyrax::UploadedFile.create(file: File.open(pdf_file))
    ]

    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci

    AttachFilesToWorkJob.perform_now(doc, uploaded_files)
  end

  scenario 'Show expected fields' do
    visit "/concern/documents/#{doc.id}"
    expect(page).to have_content doc.title.first
  end
end
