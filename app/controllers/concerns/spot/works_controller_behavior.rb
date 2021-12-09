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
  end
end
