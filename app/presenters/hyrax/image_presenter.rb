# frozen_string_literal: true
module Hyrax
  class ImagePresenter < ::Spot::BasePresenter
    include ::Spot::ExportsImageDerivatives

    delegate :contributor, :creator, :date, :date_associated,
             :date_scope_note, :description, :donor, :inscription,
             :keyword, :language_label, :local_identifier, :note,
             :original_item_extent, :permalink, :physical_medium,
             :publisher, :related_resource, :repository_location,
             :requested_by, :research_assistance, :resource_type,
             :rights_holder, :rights_statement, :standard_identifier,
             :subtitle, :title_alternative,
             to: :solr_document

    def manifest_metadata_fields
      %i[
        title subtitle title_alternative creator contributor date
        description inscription keyword language_label location
        subject subject_ocm standard_identifier rights_statement
      ]
    end

    def subject_ocm
      solr_document.subject_ocm.sort
    end
  end
end
