RSpec.feature 'Show Publication page', :js do
  let(:user) { create(:user) }
  let(:pub) { create(:publication, :public, user: user, file: file) }

  before do
    allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci

    allow_any_instance_of(Hyrax::DownloadsController)
      .to receive(:show)
      .and_return file

    allow_any_instance_of(Hyrax::FileSetPresenter)
      .to receive(presenter_check_method)
      .and_return true

    visit "/concern/publications/#{pub.id}"
  end

  context 'when Publication is a PDF' do
    let(:presenter_check_method) { :pdf? }
    let(:file) { File.open("#{::Rails.root}/spec/fixtures/document.pdf") }

    scenario 'the PDF viewer is displayed' do
      expect(page).to have_content pub.title.first

      iframe = page.find('iframe')
      expect(iframe).to be_present
      expect(iframe[:src]).to include "/web/viewer.html?file=/downloads/#{pub.file_sets.first.id}"
    end
  end

  context 'when Publication is an image' do
    let(:file) { File.open("#{::Rails.root}/spec/fixtures/image.png") }
    let(:presenter_check_method) { :image? }

    scenario 'the UniversalViewer is displayed' do
      expect(page).to have_content pub.title.first

      viewer = page.find('.uv.viewer')
      expect(viewer).to be_present
      expect(viewer[:'data-uri']).to eq "/concern/#{pub.class.to_s.downcase.pluralize}/#{pub.id}/manifest"
    end
  end
end
