# frozen_string_literal: true
module Hyrax
  class PublicationPresenter < ::Spot::BasePresenter
    humanize_date_fields :date_issued

    delegate :academic_department, :bibliographic_citation,
             :date_available, :division, :editor, :organization,
             :citation_journal_title, :citation_volume, :citation_issue,
             :citation_firstpage, :citation_lastpage,
             to: :solr_document

    def abstract
      solr_document.abstract.map { |abs| replace_line_breaks(abs) }
    end

    def description
      solr_document.description.map { |desc| replace_line_breaks(desc) }
    end
  end
end
