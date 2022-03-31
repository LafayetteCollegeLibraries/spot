# frozen_string_literal: true
module Hyrax
  class ImagePresenter < ::Spot::BasePresenter
    include ::Spot::ExportsImageDerivatives

    humanize_date_fields :date, :date_associated

    delegate :date_scope_note, :donor, :original_item_extent,
             :repository_location, :requested_by, :research_assistance,
             to: :solr_document

    def description
      solr_document.description.map { |desc| replace_line_breaks(desc) }
    end

    def inscription
      solr_document.inscription.map { |insc| replace_line_breaks(insc) }
    end

    def subject_ocm
      solr_document.subject_ocm.sort
    end
  end
end
