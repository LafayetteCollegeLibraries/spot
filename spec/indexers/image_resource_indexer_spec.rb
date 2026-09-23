# frozen_string_literal: true
#
# @todo add location + subject URI handling
RSpec.describe ImageResourceIndexer, valkyrization: true do
  subject(:solr_document) { described_class.for(resource: resource).to_solr }
  let(:resource) { ImageResource.new(**metadata) }

  let(:default_thumbnail_path) { ActionController::Base.helpers.image_path('default.png').to_s }
  let(:date) { Time.zone.today }
  let(:metadata) do
    {
      # core metadata
      title: ['Title of Image'],
      date_modified: date,
      date_uploaded: date,
      depositor: 'repository@lafayette.edu',

      # base metadata
      bibliographic_citation: ['Last, First. "Title." Journal 1.2 (2000): 1-2.'],
      contributor: ['Contributor A', 'Contributor B'],
      creator: ['Malantonio, Anna'],
      description: ['Description of work'],
      identifier: ['local:abc123'],
      keyword: ['libraries', 'test'],
      language: ['en'],
      location: ['http://sws.geonames.org/5188140/'],
      note: ['A note about the thing'],
      physical_medium: ['none'],
      publisher: ['Great Thoughts Pub'],
      related_resource: ['https://ldr.lafayette.edux'],
      resource_type: ['Article', 'Other'],
      rights_holder: ['Malantonio, Anna'],
      rights_statement: ['http://creativecommons.org/publicdomain/mark/1.0/'],
      source: ['Lafayette College'],
      source_identifier: ['test.1.1'],
      subtitle: ['a curious work'],
      title_alternative: ['another name'],

      # image_metadata
      date: ['2026-05-08'],
      date_associated: ['2026-05-08'],
      date_scope_note: ['info about the date', 'more info'],
      donor: ['A Generous Donor'],
      inscription: ['a lil note'],
      original_item_extent: ['9cm', '6oz'],
      repository_location: ['in the back room'],
      requested_by: ['A Curious Student'],
      research_assistance: ['Student A', 'Student B'],
      subject_ocm: ['000 VALUE']
    }
  end

  # rubocop:disable Layout/FirstHashElementIndentation
  it 'generates a solr document' do
    expect(solr_document).to eq({
      admin_set_id_ssim: [''], # hyrax-managed field
      admin_set_sim: nil, # hyrax-managed field
      admin_set_tesim: nil, # hyrax-managed field
      alternate_ids_sim: [], # hyrax-managed field
      bibliographic_citation_tesim: ['Last, First. "Title." Journal 1.2 (2000): 1-2.'],
      citation_firstpage_ss: '1',
      citation_issue_ss: '2',
      citation_journal_title_ss: 'Journal',
      citation_lastpage_ss: '2',
      citation_volume_ss: '1',
      contributor_tesim: ['Contributor A', 'Contributor B'],
      contributor_sim: ['Contributor A', 'Contributor B'],
      creator_tesim: ['Malantonio, Anna'],
      creator_sim: ['Malantonio, Anna'],
      date_ssim: ['2026-05-08'],
      date_associated_ssim: ['2026-05-08'], # @todo should this be _sim?
      date_associated_tesim: ['2026-05-08'],
      date_modified_dtsi: nil, # Hyrax-managed field
      date_scope_note_tesim: ['info about the date', 'more info'],
      date_sort_dtsi: '2026-05-08T00:00:00Z',
      date_uploaded_dtsi: nil, # not applied before save
      depositor_ssim: ['repository@lafayette.edu'], # Hyrax-managed field
      depositor_tesim: ['repository@lafayette.edu'], # Hyrax-managed field
      description_tesim: ['Description of work'],
      donor_ssim: ['A Generous Donor'],
      edit_access_group_ssim: [], # Hyrax-managed field
      edit_access_person_ssim: [], # Hyrax-managed field
      embargo_history_ssim: nil, # Hyrax-managed field
      generic_type_si: 'Work', # Hyrax-managed field
      hasRelatedImage_ssim: [''], # Hyrax-managed field
      hasRelatedMediaFragment_ssim: [''], # Hyrax-managed field
      has_model_ssim: 'ImageResource', # Hyrax-managed field
      human_readable_type_sim: 'Image Resource', # Hyrax-managed field
      human_readable_type_tesim: 'Image Resource', # Hyrax-managed field
      id: '', # Hyrax-managed field
      identifier_ssim: ['local:abc123'],
      inscription_tesim: ['a lil note'],
      isPartOf_ssim: [''], # Hyrax-managed field
      keyword_tesim: ['libraries', 'test'],
      keyword_sim: ['libraries', 'test'],
      language_ssim: ['en'],
      language_label_ssim: ['English'],
      lease_history_ssim: nil, # Hyrax-managed field
      member_ids_ssim: [], # Hyrax-managed field
      member_of_collection_ids_ssim: [], # Hyrax-managed field
      note_tesim: ['A note about the thing'],
      original_item_extent_tesim: ['9cm', '6oz'],
      physical_medium_sim: ['none'],
      physical_medium_tesim: ['none'],
      publisher_sim: ['Great Thoughts Pub'],
      publisher_tesim: ['Great Thoughts Pub'],
      read_access_group_ssim: [], # Hyrax-managed field
      read_access_person_ssim: [], # Hyrax-managed field
      related_resource_sim: ['https://ldr.lafayette.edux'],
      related_resource_tesim: ['https://ldr.lafayette.edux'],
      repository_location_ssim: ['in the back room'],
      requested_by_ssim: ['A Curious Student'],
      research_assistance_ssim: ['Student A', 'Student B'],
      resource_type_ssim: ['Article', 'Other'],
      rights_holder_tesim: ['Malantonio, Anna'],
      rights_holder_sim: ['Malantonio, Anna'],
      rights_statement_ssim: ['http://creativecommons.org/publicdomain/mark/1.0/'],
      rights_statement_label_ssim: ['Public Domain Mark'],
      rights_statement_shortcode_ssim: ['PDM'],
      source_tesim: ['Lafayette College'],
      source_sim: ['Lafayette College'],
      source_identifier_ssim: ['test.1.1'],
      subject_ocm_ssim: ['000 VALUE'],
      subject_ocm_tesim: ['000 VALUE'],
      subtitle_tesim: ['a curious work'],
      subtitle_sim: ['a curious work'],
      suppressed_bsi: false, # Hyrax-managed field
      system_create_dtsi: nil, # Hyrax-managed field
      system_modified_dtsi: nil, # Hyrax-managed field
      thumbnail_path_ss: default_thumbnail_path, # Hyrax-managed field
      title_sim: ['Title of Image'],
      title_tesim: ['Title of Image'],
      title_alternative_tesim: ['another name'],
      title_alternative_sim: ['another name'],
      visibility_ssi: 'restricted', # Hyrax-managed field
      years_encompassed_iim: [2026]
    }.with_indifferent_access)
  end
  # rubocop:enable Layout/FirstHashElementIndentation
end
