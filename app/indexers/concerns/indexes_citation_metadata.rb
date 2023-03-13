module IndexesCitationMetadata
    extend ActiveSupport::Concern

    def generate_solr_document
        super.tap do |doc|
            next doc if object.bibliographic_citation.empty?

            @citation = AnyStyle.parse(object.bibliographic_citation.first)

            doc['citation_journal_title_ss'] = puts @citation.first[:"container-title"].first.to_s if @citation.respond_to?(:"container-title")
            doc['citation_volume_ss'] = puts @citation.first[:"volume"].first.to_s if @citation.respond_to?(:"volume")
            doc['citation_issue_ss'] = puts @citation.first[:"issue"].first.to_s if @citation.respond_to?(:"issue")
            doc['citation_firstpage_ss'] = puts @citation.first[:"pages"].first.to_s.split('–', 2).first if @citation.respond_to?(:"pages")
            doc['citation_lastpage_ss'] = puts @citation.first[:"pages"].first.to_s.split('–', 2).last if @citation.respond_to?(:"pages")
        end
    end
end