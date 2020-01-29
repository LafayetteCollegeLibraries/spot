# frozen_string_literal: true
module Hyrax
  class ImagePresenter < ::Spot::BasePresenter
    delegate :contributor, :creator, :date, :date_associated,
             :date_scope_note, :description, :donor, :ethnic_group,
             :inscription, :keyword, :language_label, :local_identifier,
             :note, :original_item_extent, :physical_medium, :publisher,
             :related_resource, :repository, :requested_by,
             :research_assistance, :resource_type, :rights_holder,
             :rights_statement, :standard_identifier,
             :subject_ocm, :subtitle, :title_alternative,
             to: :solr_document
  end
end
