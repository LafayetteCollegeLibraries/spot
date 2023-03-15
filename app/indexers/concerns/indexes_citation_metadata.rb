# frozen_string_literal: true
module IndexesCitationMetadata
  extend ActiveSupport::Concern

  def generate_solr_document
    super.tap do |doc|
      next doc if object.bibliographic_citation.empty?

      citation = AnyStyle.parse(object.bibliographic_citation.first)

      next doc if citation.blank?

      citaton = citation.first

      entry = citation[:"container-title"].blank? ? [""] : entry[:"container-title"]

      doc['citation_journal_title_ss'] = entry.first
      doc['citation_volume_ss'] = citation[:"volume"].blank? ? "" : citation[:"volume"].first
      doc['citation_issue_ss'] = citation[:"issue"].blank? ? "" : citation[:"issue"].first
      doc['citation_firstpage_ss'] = citation[:"pages"].blank? ? "" : citation[:"pages"].first.split('–', 2).first
      doc['citation_lastpage_ss'] = citation[:"pages"].blank? ? "" : citation[:"pages"].first.split('–', 2).last
    end
  end
end
