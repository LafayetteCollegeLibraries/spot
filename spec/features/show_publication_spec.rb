RSpec.feature 'Show Publication page', js: false do
  let(:user) { create(:user) }
  let(:pub) { create(:publication, user: user, file: file, language: language) }
  let(:item_base_url) { "/concern/#{pub.class.to_s.downcase.pluralize}/#{pub.id}" }
  let(:language) { ['en'] }

  # these were previously defined in the 'Publication is a PDF' context
  # but if we're checking metadata outside of that scope we'll need these
  # to be defined, and why not use PDFs when they're expected to be the
  # bulk of this work type
  let(:presenter_check_method) { :pdf? }
  let(:file) { create(:uploaded_pdf) }

  # Only enqueue the ingest job, not charactarization.
  # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
  before do
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    # Since we're not passing our objects through charactarization,
    # we need to pretend we did and mock a `:presenter_check_method`
    # to return true in order to
    allow_any_instance_of(Hyrax::FileSetPresenter)
      .to receive(presenter_check_method)
      .and_return true

    visit item_base_url
  end

  scenario 'metadata fields are present' do
    expect(page).to have_content pub.title.first

    # descriptions are treated differently
    expect(page.all('.work_description').map(&:text))
      .to eq pub.description.map(&:to_s)

    expect(page.all('.attribute-abstract').map(&:text))
      .to eq pub.abstract.map(&:to_s)
    expect(page.all('.attribute-academic_department').map(&:text))
      .to eq pub.academic_department.map(&:to_s)
    expect(page.all('.attribute-bibliographic_citation').map(&:text))
      .to eq pub.bibliographic_citation.map(&:to_s)
    expect(page.all('.attribute-contributor').map(&:text))
      .to eq pub.contributor.map(&:to_s)
    expect(page.all('.attribute-creator').map(&:text))
      .to eq pub.creator.map(&:to_s)
    expect(page.all('.attribute-date_issued').map(&:text))
      .to eq pub.date_issued.map(&:to_s)
    expect(page.all('.attribute-date_available').map(&:text))
      .to eq pub.date_available.map(&:to_s)
    expect(page.all('.attribute-division').map(&:text))
      .to eq pub.division.map(&:to_s)
    expect(page.all('.attribute-editor').map(&:text))
      .to eq pub.editor.map(&:to_s)
    expect(page.all('.attribute-keyword').map(&:text))
      .to eq pub.keyword.map(&:to_s)
    expect(page.all('.attribute-organization').map(&:text))
      .to eq pub.organization.map(&:to_s)
    expect(page.all('.attribute-publisher').map(&:text))
      .to eq pub.publisher.map(&:to_s)
    expect(page.all('.attribute-resource_type').map(&:text))
      .to eq pub.resource_type.map(&:to_s)
    expect(page.all('.attribute-source').map(&:text))
      .to eq pub.source.map(&:to_s)
    expect(page.all('.attribute-subject').map(&:text))
      .to eq pub.subject.map(&:to_s)
    expect(page.all('.attribute-subtitle').map(&:text))
      .to eq pub.subtitle.map(&:to_s)
    expect(page.all('.attribute-title_alternative').map(&:text))
      .to eq pub.title_alternative.map(&:to_s)

    expect(page.all('.attribute-language_label').map(&:text))
      .to eq ['English']

    # @todo there's _got_ to be a better way!!
    pub.identifier.each do |id|
      key = id.split(':').first
      all_clean = page.all(".attribute-identifier_#{key}").map do |value|
                    value.text.downcase.sub(' ', ':').sub('handle', 'hdl')
                  end
      expect(all_clean).to include id
    end

    # TODO: revisit Rights Statement when we actually display it on the show page
    #expect(page.all('.attribute-rights_statement').map(&:uri))
    #  .to eq pub.rights_statement.map(&:to_s)
  end

  context 'when Publication is a PDF' do
    scenario 'the PDF viewer is displayed' do
      iframe = page.find('iframe')
      expect(iframe).to be_present
      expect(iframe[:src]).to include "/web/viewer.html?file=/downloads/#{pub.file_sets.first.id}"
    end
  end

  context 'when Publication is an image' do
    let(:file) { create(:uploaded_image) }
    let(:presenter_check_method) { :image? }

    scenario 'the UniversalViewer is displayed' do
      viewer = page.find('.uv.viewer')
      expect(viewer).to be_present
      expect(viewer[:'data-uri']).to eq "#{item_base_url}/manifest"
    end
  end
end
