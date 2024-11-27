# frozen_string_literal: true
module IndexesCitationMetadata
  def to_solr
    super.tap do |doc|
      citation = work_citation
      next doc if citation.blank?

      add_citation_to_solr_document(document: doc, citation: citation)
    end
  end

  alias generate_solr_document to_solr

  def add_citation_to_solr_document(document:, citation:)
    document['citation_journal_title_ss'] = citation[:"container-title"]&.first
    document['citation_volume_ss'] = citation[:volume]&.first
    document['citation_issue_ss'] = citation[:issue]&.first

    # split pages on any type of hyphen (*waves fist at em and en dashes*)
    first_page, last_page = citation[:pages]&.first&.split(/[-–—]/, 2)
    document['citation_firstpage_ss'] = first_page
    document['citation_lastpage_ss'] = last_page
  end

  # @return [Hash<Symbol => *>, nil]
  def work_citation
    work = try(:resource) || object
    return if work.try(:bibliographic_citation).blank?

    citation = ::AnyStyle.parse(Array.wrap(work.bibliographic_citation).first)&.first
    citation unless citation.blank? || citation[:type].nil?
  end
end
