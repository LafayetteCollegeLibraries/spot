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

    included do
      before_action :load_workflow_presenter, only: :edit
      after_action  :update_workflow_flash, only: :update

      self.work_form_service = Spot::WorkFormService
    end

    private

    # @note valkyrie forms only accept the resource in the initializer,
    #       so our specs are currently failing when HYRAX_VALKYRIE=1.
    #       I'm assuming this is fixed upstream, so I'm just going to
    #       patch this for now.
    # @todo Remove when Hyrax > 5
    # def build_form
    #   super()
    # rescue ArgumentError
    #   @form = work_form_service.form_class(curation_concern).new(curation_concern)
    # end

    def additional_response_formats(wants)
      super

      wants.csv do
        content = Spot::WorkCsvService.new(presenter.solr_document).csv
        send_data(content, type: 'text/csv', filename: "#{presenter.id}.csv")
      end
    end

    # Overrides Hyrax behavior by using our own IIIF presenter that relies on Blacklight locales
    # to generate field labels.
    #
    # @return [Spot::IiifManifestPresenter]
    # @todo is there a way we can add test coverage for this?
    #
    # :nocov:
    def iiif_manifest_presenter
      ::Spot::IiifManifestPresenter.new(search_result_document(id: params[:id], defType: 'lucene')).tap do |p|
        p.hostname = request.hostname
        p.ability = current_ability
      end
    end
    # :nocov:

    def load_workflow_presenter
      @workflow_presenter = Hyrax::WorkflowPresenter.new(::SolrDocument.find(params[:id]), current_ability)
    end

    # @see https://github.com/samvera/hyrax/blob/hyrax-v3.6.0/app/controllers/concerns/hyrax/works_controller_behavior.rb#L252-L253
    # @todo is there a way we can add test coverage for this?
    #
    # :nocov:
    def search_params
      params.deep_dup.tap do |sp|
        sp.delete(:page)
      end
    end
    # :nocov:

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
