module IndexesCitationMetadata
  extend ActiveSupport::Concern

  def generate_solr_document
    super.tap do |doc|
      next doc if object.bibliographic_citation.empty?

      @citation = AnyStyle.parse(object.bibliographic_citation.first)

      next doc if @citation.blank?
      doc['citation_journal_title_ss'] = @citation.first[:"container-title"].blank? ? "" : @citation.first[:"container-title"].first.to_s
      doc['citation_volume_ss'] = @citation.first[:"volume"].blank? ? "" : @citation.first[:"volume"].first.to_s
      doc['citation_issue_ss'] = @citation.first[:"issue"].blank? ? "" : @citation.first[:"issue"].first.to_s
      doc['citation_firstpage_ss'] = @citation.first[:"pages"].blank? ? "" : @citation.first[:"pages"].first.to_s.split('–', 2).first
      doc['citation_lastpage_ss'] = @citation.first[:"pages"].blank? ? "" : @citation.first[:"pages"].first.to_s.split('–', 2).last
    end
  end
end
