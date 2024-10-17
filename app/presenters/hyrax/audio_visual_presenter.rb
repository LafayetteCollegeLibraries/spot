# frozen_string_literal: true
module Hyrax
  class AudioVisualPresenter < ::Spot::BasePresenter
    humanize_date_fields :date, :date_associated

    delegate :stored_derivatives, :premade_derivatives, 
             :original_item_extent, :repository_location, :research_assistance, 
             :provenance, :barcode,
             to: :solr_document

    def description
      solr_document.description.map { |desc| replace_line_breaks(desc) }
    end

    def inscription
      solr_document.inscription.map { |insc| replace_line_breaks(insc) }
    end
  end
end
