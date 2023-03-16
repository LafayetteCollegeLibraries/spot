# frozen_string_literal: true
module IndexesCitationMetadata
  extend ActiveSupport::Concern

  def generate_solr_document
    super.tap do |doc|
      next doc if object.bibliographic_citation.empty?

      citation = AnyStyle.parse(object.bibliographic_citation.first)

      next doc if citation.blank?

      entry = citation.first

      doc['citation_journal_title_ss'] ||= entry[:"container-title"]&.first
      doc['citation_volume_ss'] ||= entry[:"volume"]&.first
      doc['citation_issue_ss'] ||= entry[:"issue"]&.first
      doc['citation_firstpage_ss'] ||= entry[:"pages"]&.first&.split('–', 2)&.first
      doc['citation_lastpage_ss'] ||= entry[:"pages"]&.first&.split('–', 2)&.last
    end
  end
end
