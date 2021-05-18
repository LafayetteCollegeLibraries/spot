# frozen_string_literal: true
module Hyrax
  class PublicationPresenter < ::Spot::BasePresenter
    humanize_date_fields :date_issued

    delegate :abstract, :academic_department, :bibliographic_citation,
             :date_available, :division, :editor, :organization,
             to: :solr_document
  end
end
