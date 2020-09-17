# frozen_string_literal: true
RSpec.feature 'Show Publication page', js: false do
  include ::Hyrax::IiifHelper

  let(:pub) do
    create(:publication_with_file_set,
           content: file,
           language: language,
           subject: [RDF::URI(subject_uri)])
  end

  let(:url_host) { ENV['URL_HOST'] }
  let(:item_base_url) { "#{url_host}/concern/publications/#{pub.id}" }
  let(:language) { ['en'] }
  let(:subject_uri) { 'http://id.worldcat.org/fast/2004076' }
  let(:subject_label) { 'Little free libraries' }

  # these were previously defined in the 'Publication is a PDF' context
  # but if we're checking metadata outside of that scope we'll need these
  # to be defined, and why not use PDFs when they're expected to be the
  # bulk of this work type
  let(:presenter_check_method) { :pdf? }
  let(:file) { File.open(Rails.root.join('spec', 'fixtures', 'document.pdf')) }

  # Only enqueue the ingest job, not charactarization.
  # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
  before do
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    RdfLabel.first_or_create(uri: subject_uri, value: subject_label)

    # Since we're not passing our objects through charactarization,
    # we need to pretend we did and mock a `:presenter_check_method`
    # to return true in order to get the appropriate viewer to display
    #
    allow_any_instance_of(Hyrax::FileSetPresenter) # rubocop:disable RSpec/AnyInstance
      .to receive(presenter_check_method)
      .and_return true

    visit item_base_url
  end

  scenario 'metadata fields are present' do
    expect(page).to have_content pub.title.first
    expect(page.title).to eq "#{pub.title.first} // Lafayette Digital Repository"

    # descriptions are treated differently
    # expect(page.all('.work_description').map(&:text))
    #   .to eq pub.description.map(&:to_s)

    # expect(page.all('.attribute-abstract').map(&:text))
    #   .to eq pub.abstract.map(&:to_s)

    expect(page.all('.attribute-academic_department').map(&:text))
      .to eq pub.academic_department.map(&:to_s)
    expect(page.all('.attribute-bibliographic_citation').map(&:text))
      .to eq pub.bibliographic_citation.map(&:to_s)
    expect(page.all('.attribute-contributor').map(&:text))
      .to eq pub.contributor.map(&:to_s)
    expect(page.all('.attribute-creator').map(&:text))
      .to eq pub.creator.map(&:to_s)
    expect(page.all('.attribute-date_issued').map(&:text))
      .to eq pub.date_issued.map(&:to_s).map { |d| Date.edtf(d).humanize }
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
    expect(page.all('.attribute-subtitle').map(&:text))
      .to eq pub.subtitle.map(&:to_s)
    expect(page.all('.attribute-title_alternative').map(&:text))
      .to eq pub.title_alternative.map(&:to_s)
    expect(page.all('.attribute-language_label').map(&:text))
      .to eq ['English']

    # the weird space is a result of the font-awesome external-link gliph
    # not containing any text value, but being an html node that is replaced.
    mapped_subjects = pub.subject.map do |sub|
      label = RdfLabel.find_by(uri: sub.id).value
      "#{label} (view authority )"
    end

    expect(page.all('.attribute-subject').map(&:text)).to eq mapped_subjects

    # @todo there's _got_ to be a better way!!

    standard_identifiers = page.all('.attribute-standard_identifier').map do |value|
      value.text.downcase.sub(' ', ':').sub('handle', 'hdl')
    end

    pub.identifier
       .map { |id| Spot::Identifier.from_string(id) }
       .select(&:standard?)
       .each { |id| expect(standard_identifiers).to include id.to_s }

    local_identifiers = page.all('.attribute-local_identifier').map(&:text)
    expect(local_identifiers).to be_empty # user we're testing as isn't able to see the repository info partial

    # TODO: revisit Rights Statement when we actually display it on the show page
    # expect(page.all('.attribute-rights_statement').map(&:uri))
    #   .to eq pub.rights_statement.map(&:to_s)
  end

  context 'when Publication is a PDF' do
    scenario 'the PDF viewer is displayed' do
      iframe = page.find('iframe')
      expect(iframe).to be_present
      expect(iframe[:src]).to include "/web/viewer.html?file=/downloads/#{pub.file_sets.first.id}"
    end
  end

  context 'when Publication is an image' do
    let(:file) { File.open(Rails.root.join('spec', 'fixtures', 'image.png')) }
    let(:presenter_check_method) { :image? }
    let(:url_host) { ENV['URL_HOST'] }
    let(:viewer_src) { "#{url_host}/uv/uv.html#?manifest=#{item_base_url}/manifest&config=#{url_host}/uv/uv-config.json" }

    scenario 'the UniversalViewer is displayed' do
      viewer = page.find('.viewer-wrapper iframe')
      expect(viewer).to be_present
      expect(viewer[:src]).to eq viewer_src
    end
  end
end
