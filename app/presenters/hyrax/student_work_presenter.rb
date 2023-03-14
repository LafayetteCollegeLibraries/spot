# frozen_string_literal: true
module Hyrax
  class StudentWorkPresenter < Spot::BasePresenter
    humanize_date_fields :date, :date_available

    delegate :access_note, :advisor, :advisor_label, :bibliographic_citation,
             :academic_department, :division, :organization,
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
