# frozen_string_literal: true
module Hyrax
  class StudentWorkPresenter < Spot::BasePresenter
    humanize_date_fields :date, :date_available

    delegate :abstract, :access_note, :advisor, :bibliographic_citation, to: :solr_document
  end
end
