# frozen_string_literal: true
module Spot
  # abstracts out a +:iiif_manifest_presenter_klass+ attribute to override the Hyrax one.
  # in our case, we want to change how the metadata is rendered.
  #
  # @see https://github.com/samvera/hyrax/blob/v2.9.0/app/controllers/concerns/hyrax/works_controller_behavior.rb#L146-L151
  module ConfigurableIiifManifestPresenter
    extend ActiveSupport::Concern

    included do
      class_attribute :iiif_manifest_presenter_klass
      self.iiif_manifest_presenter_klass = ::Spot::IiifManifestPresenter
    end

    private

      # same behavior as Hyrax::WorksControllerBehavior#iiif_manifest_presenter,
      # but uses the configurable +:iiif_manifest_presenter_klass+ attribute
      # to allow for other subclassed presenters.
      #
      # @return [Hyrax::IiifManifestPresenter]
      def iiif_manifest_presenter
        iiif_manifest_presenter_klass.new(curation_concern_from_search_results).tap do |p|
          p.hostname = request.hostname
          p.ability = current_ability
        end
      end
  end
end
