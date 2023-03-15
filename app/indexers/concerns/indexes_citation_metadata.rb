module IndexesCitationMetadata
  extend ActiveSupport::Concern

  def generate_solr_document
    super.tap do |doc|
      next doc if object.bibliographic_citation.empty?

      @citation = AnyStyle.parse(object.bibliographic_citation.first)

      next doc if @citation.blank?

      entry = @citation.first

      doc['citation_journal_title_ss'] = entry[:"container-title"].blank? ? "" : entry[:"container-title"].first.to_s
      doc['citation_volume_ss'] = entry[:"volume"].blank? ? "" : entry[:"volume"].first.to_s
      doc['citation_issue_ss'] = entry[:"issue"].blank? ? "" : entry[:"issue"].first.to_s
      doc['citation_firstpage_ss'] = entry[:"pages"].blank? ? "" : entry[:"pages"].first.to_s.split('–', 2).first
      doc['citation_lastpage_ss'] = entry[:"pages"].blank? ? "" : entry[:"pages"].first.to_s.split('–', 2).last
    end
  end
end
