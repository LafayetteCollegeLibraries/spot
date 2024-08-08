# frozen_string_literal: true
module Hyrax
  class AudioVisualPresenter < ::Spot::BasePresenter
    delegate :title, :date, :stored_derivatives, :premade_derivatives, to: :solr_document

    humanize_date_fields :date
  end
end
