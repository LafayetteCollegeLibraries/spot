# frozen_string_literal: true
module IndexesCitationMetadata
  def generate_solr_document
    super.tap do |doc|
      # bibliographic_citation is a part of Spot::CoreMetadata, which is included on all works,
      # but this should safeguard in the event that's not the case in the future
      next doc unless object.respond_to?(:bibliographic_citation) && object.bibliographic_citation.present?

      # exit early if the citation parses incorrectly
      citation = AnyStyle.parse(object.bibliographic_citation.first)&.first
      next doc if citation.blank? || citation[:type].nil?

      doc['citation_journal_title_ss'] = citation[:"container-title"]&.first
      doc['citation_volume_ss'] = citation[:volume]&.first
      doc['citation_issue_ss'] = citation[:issue]&.first

      # split pages on any type of hyphen (*waves fist at em and en dashes*)
      first_page, last_page = citation[:pages]&.first&.split(/[-–—]/, 2)
      doc['citation_firstpage_ss'] = first_page
      doc['citation_lastpage_ss'] = last_page
    end
  end
end
