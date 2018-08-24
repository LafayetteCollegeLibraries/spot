RSpec.feature 'Show Publication page', js: false do
  let(:user) { create(:user) }
  let(:pub) { create(:publication, user: user, file: file) }
  let(:item_base_url) { "/concern/#{pub.class.to_s.downcase.pluralize}/#{pub.id}" }

  # Only enqueue the ingest job, not charactarization.
  # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
  before do
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    # Since we're not passing our objects through charactarization,
    # we need to pretend we did and mock a `:presenter_check_method`
    # to return true
    allow_any_instance_of(Hyrax::FileSetPresenter)
      .to receive(presenter_check_method)
      .and_return true

    visit item_base_url
  end

  context 'when Publication is a PDF' do
    let(:presenter_check_method) { :pdf? }
    let(:file) { create(:uploaded_pdf) }

    scenario 'the PDF viewer is displayed' do
      expect(page).to have_content pub.title.first

      iframe = page.find('iframe')
      expect(iframe).to be_present
      expect(iframe[:src]).to include "/web/viewer.html?file=/downloads/#{pub.file_sets.first.id}"
    end
  end

  context 'when Publication is an image' do
    let(:file) { create(:uploaded_image) }
    let(:presenter_check_method) { :image? }

    scenario 'the UniversalViewer is displayed' do
      expect(page).to have_content pub.title.first

      viewer = page.find('.uv.viewer')
      expect(viewer).to be_present
      expect(viewer[:'data-uri']).to eq "#{item_base_url}/manifest"
    end
  end
end
