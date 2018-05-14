RSpec.feature 'Show Publication page', :js do
  let(:user) { create(:user) }
  let(:pdf) { File.open("#{::Rails.root}/spec/fixtures/image-document.pdf") }
  let(:pub) { create(:publication, :public, user: user, file: pdf) }

  before do
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
  end

  scenario 'the PDF viewer is displayed' do
    allow_any_instance_of(Hyrax::FileSetHelper)
      .to receive(:media_display_partial)
      .and_return 'hyrax/file_sets/media_display/pdf'

    allow_any_instance_of(Hyrax::DownloadsController)
      .to receive(:show)
      .and_return pdf

    visit "/concern/publications/#{pub.id}"

    expect(page).to have_content pub.title.first

    iframe = page.find('iframe')
    expect(iframe).to be_present
    expect(iframe[:src]).to include "/web/viewer.html?file=/downloads/#{pub.file_sets.first.id}"
  end
end
