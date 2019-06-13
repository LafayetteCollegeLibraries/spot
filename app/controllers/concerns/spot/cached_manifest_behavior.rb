# frozen_string_literal: true
#
# Overrides the Hyrax::WorksControllerBehavior#manifest method to prevent
# generating a new manifest on every request. Uses the Solr document's
# '_version_' property to ensure that we're not retrieving an older
# version of the object from the cache. Also adds a `manifest_cache_duration`
# attribute to set how long you want the thing sticking around.
#
# @example
#   module Hyrax
#     class CoolWorksController < ApplicationController
#       # get that hyrax good-good
#       include Hyrax::WorksControllerBehavior
#       include Hyrax::BreadcrumbsForWorks
#
#       # cache the manifests!
#       include Spot::CachedManifestBehavior
#
#       self.manifest_cache_duration = 180.days
#     end
#   end
#
# @todo remove the meta-programming (see +included+ block) once we upgrade to Hyrax@3
module Spot
  module CachedManifestBehavior
    extend ActiveSupport::Concern

    included do
      class_attribute :manifest_cache_duration
      self.manifest_cache_duration = 30.days

      # In Hyrax@3 the manifests generated are sanitized/cleaned-up.
      # Meta-programming will allow us to prefer those methods and
      # fall-back to defining them using the Hyrax@3 code.
      unless method_defined?(:sanitize_manifest)
        define_method(:sanitize_manifest) do |hash|
          hash['label'] = sanitize_value(hash['label']) if hash.key?('label')
          hash['description'] = hash['description']&.collect { |elem| sanitize_value(elem) } if hash.key?('description')

          hash['sequences']&.each do |sequence|
            sequence['canvases']&.each do |canvas|
              canvas['label'] = sanitize_value(canvas['label'])
            end
          end
          hash
        end
      end

      unless method_defined?(:sanitize_value)
        define_method(:sanitize_value) do |text|
          Loofah.fragment(text.to_s).scrub!(:prune).to_s
        end
      end
    end

    def manifest
      headers['Access-Control-Allow-Origin'] = '*'

      # this is the only thing we're doing differently than Hyrax w/ this method
      json = Rails.cache.fetch(manifest_cache_key, expires_in: manifest_cache_duration) do
        sanitize_manifest(JSON.parse(manifest_builder.to_h.to_json))
      end

      respond_to do |wants|
        wants.json { render json: json }
        wants.html { render json: json }
      end
    end

    private

      # By adding the Solr '_version_' field to the cache key, we shouldn't
      # run into the problem of fetching an outdated version of the manifest.
      #
      # @return [String]
      def manifest_cache_key
        "#{presenter.id}/#{presenter.solr_document['_version_']}"
      end
  end
end
