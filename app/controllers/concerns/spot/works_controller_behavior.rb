# frozen_string_literal: true
module Spot
  # Base controller for Works that we can inherit from. Inherits Hyrax work behaviors
  # as well as handling for CSVs and using our own IIIF presenter.
  #
  # @example usage
  #   class DigitizedResourcesController < ApplicationController
  #     include Spot::WorksControllerBehavior
  #   end
  #
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include ::Hyrax::WorksControllerBehavior
    include ::Hyrax::BreadcrumbsForWorks
    include AdditionalFormatsForController

    included do
      before_action :load_workflow_presenter, only: :edit
      after_action  :update_workflow_flash, only: :update
    end

    private

    # Overrides Hyrax behavior by using our own IIIF presenter that relies on Blacklight locales
    # to generate field labels.
    #
    # @return [Spot::IiifManifestPresenter]
    def iiif_manifest_presenter
      ::Spot::IiifManifestPresenter.new(curation_concern_from_search_results).tap do |p|
        p.hostname = request.hostname
        p.ability = current_ability
      end
    end

    def load_workflow_presenter
      @workflow_presenter = Hyrax::WorkflowPresenter.new(::SolrDocument.find(params[:id]), current_ability)
    end

    # When the workflow presenter has actions available, append a note to the update flash that the
    # review form needs to be marked as completed.
    #
    # @return [void]
    def update_workflow_flash
      return unless flash[:notice].present? && presenter.workflow&.actions.present?

      flash[:notice] += " <strong>Finished making edits? Be sure to mark the review form as complete.</strong>"
    end
  end
end
