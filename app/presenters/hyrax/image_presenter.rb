# frozen_string_literal: true
module Hyrax
  class ImagePresenter < ::Spot::BasePresenter
    include ::Spot::ExportsImageDerivatives

    humanize_date_fields :date, :date_associated

    delegate :contributor, :creator, :date_scope_note, :description,
             :donor, :inscription, :keyword, :language_label,
             :local_identifier, :note, :original_item_extent, :permalink,
             :physical_medium, :publisher, :related_resource, :repository_location,
             :requested_by, :research_assistance, :resource_type,
             :rights_holder, :rights_statement, :source,
             :standard_identifier, :subtitle, :title_alternative,
             to: :solr_document

    def subject_ocm
      solr_document.subject_ocm.sort
    end
  end
end
