# frozen_string_literal: true
RSpec.feature 'Show Student Work page', js: false do
  include ::Hyrax::IiifHelper

  let(:work) do
    create(:student_work_with_file_set,
           content: file,
           language: ['en'],
           date: ['2021-02-11'],
           date_available: ['2021-02-11'],
           advisor: [advisor_email],
           subject: [RDF::URI(subject_uri)])
  end

  let(:url_host) { ENV['URL_HOST'] }
  let(:item_base_url) { "#{url_host}/concern/student_works/#{work.id}" }
  let(:subject_uri) { 'http://id.worldcat.org/fast/794949' }
  let(:subject_label) { 'Academic achievement' }
  let(:advisor_email) { 'smartfep@lafayette.edu' }
  let(:advisor_label) { 'Smartfellow, Prof' }

  # see `before` block for how this used
  let(:presenter_check_method) { :pdf? }
  let(:file) { File.open(Rails.root.join('spec', 'fixtures', 'document.pdf')) }

  before do
    stub_env('LAFAYETTE_WDS_API_KEY', 'abc123def!')

    # Only enqueue the ingest job, not charactarization.
    # (h/t: https://github.com/curationexperts/mahonia/blob/89b036c/spec/features/access_etd_spec.rb#L9-L10)
    ActiveJob::Base.queue_adapter.filter = [IngestJob]

    Qa::LocalAuthorityEntry.find_or_create_by(local_authority: Qa::LocalAuthority.find_or_create_by(name: 'lafayette_instructors'),
                                              uri: advisor_email,
                                              label: advisor_label)
    RdfLabel.find_or_create_by(uri: subject_uri, value: subject_label)

    # Since we're not passing our objects through characterization,
    # we need to pretend we did by mocking a `:presenter_check_method`
    # to return true in order to get the appropriate viewer to display
    allow_any_instance_of(Hyrax::FileSetPresenter)
      .to receive(presenter_check_method)
      .and_return true

    visit item_base_url
  end

  after do
    RdfLabel.destroy_all
  end

  scenario 'metadata fields are present' do
    def expect_field_to_be_rendered(field)
      expect(page.all(".attribute-#{field}").map(&:text)).to eq(work.send(field).map(&:to_s))
    end

    def expect_field_to_be_faceted(field)
      expect_field_to_be_rendered(field)
      expect(page.all(".attribute-#{field} a")).not_to be_empty
    end

    expect(page).to have_content work.title.first
    expect(page.title).to eq "#{work.title.first} // Lafayette Digital Repository"

    expect_field_to_be_rendered :title
    expect_field_to_be_rendered :creator

    expect(page.all('.attribute-advisor_label').map(&:text)).to eq([advisor_label])

    expect_field_to_be_faceted  :academic_department
    expect_field_to_be_faceted  :division
    expect_field_to_be_rendered :description

    # date and date_available are humanized
    expect(page.all('.attribute-date').map(&:text)).to eq(['February 11, 2021'])
    expect(page.all('.attribute-date_available').map(&:text)).to eq(['February 11, 2021'])

    expect_field_to_be_faceted  :resource_type
    expect_field_to_be_rendered :abstract

    expect(page.all('.attribute-language_label').map(&:text)).to eq(['English'])

    expect_field_to_be_rendered :related_resource
    expect_field_to_be_rendered :access_note
    expect_field_to_be_faceted  :organization

    # this trailing space is needed because we're using an icon that #text replaces with a blank space
    expect(page.all('.attribute-subject').map(&:text)).to eq(["#{subject_label} (view authority )"])
    expect(page.all('.attribute-subject a')).not_to be_empty

    expect_field_to_be_faceted  :keyword
    expect_field_to_be_rendered :bibliographic_citation

    standard_id_values = work.identifier.map { |id| Spot::Identifier.from_string(id) }.select(&:standard?).map(&:value)
    displayed_id_values = page.all('.attribute-standard_identifier').map { |v| v.text.gsub(/^\w+\s/, '') }
    expect(displayed_id_values).to eq(standard_id_values)

    expect_field_to_be_rendered :note

    # @todo test rights statement is rendered correctly
  end

  context 'when StudentWork is a PDF' do
    scenario 'the PDF viewer is displayed' do
      iframe = page.find('iframe')
      expect(iframe).to be_present
      expect(iframe[:src]).to include "/web/viewer.html?file=/downloads/#{work.file_sets.first.id}"
    end
  end

  context 'when StudentWork is an image' do
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
