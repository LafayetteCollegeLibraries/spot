# frozen_string_literal: true
require 'uri'

module Spot
  # Controller responsible for redirecting requests from legacy services
  # (in particular, our Islandora instance) to their migrated counterparts.
  # For items that have a legacy URL, an identifier value is added with
  # a +url:+ prefix. Redirect rules should be implemented on legacy services
  # to send the entire URL as a parameter value.
  #
  # @example httpd rewrite rules
  #   RewriteEngine on
  #   RewriteRule ^collections\/[a-z0-9\-]+/[a-z0-9\-]+ https://ldr.lafayette.edu/redirect?url=http://digital.lafayette.edu%{REQUEST_URI} [L,QSA]
  #
  # @todo This should be abstracted out, as the {IdentifierController}
  #       (soon to be HandleController) follows (almost) the same  logic.
  class RedirectController < ApplicationController
    include ::Hydra::Catalog

    def show
      # all that we need for this controller are the object's ID + Hydra Model
      query = solr_query_for_identifier.merge(fl: ['id', 'has_model_ssim'])
      result, _documents = repository.search(query)

      raise Blacklight::Exceptions::RecordNotFound if result.response['numFound'].zero?

      document = result.response['docs'].first
      controller = document['has_model_ssim'].first.downcase.pluralize

      redirect_to controller: "hyrax/#{controller}", action: 'show', id: document['id']
    end

    private

      # Converts the passed URI into an HTTP URI
      # @return [String]
      def http_uri
        URI::HTTP.build(parse_uri_into_args).to_s
      end

      # Breaks a URI string into a Hash of URI component parts
      #
      # @param [String] uri_string Any kind of URI that works with +URI.parse+
      # @return [Hash<Symbol => String, nil>]
      def parse_uri_into_args
        parsed = URI.parse(params[:url])

        URI::Generic.component.each_with_object({}) do |component, obj|
          obj[component.to_sym] = parsed.send(component)
        end
      end

      def solr_query_for_identifier
        { defType: 'lucene', q: "{!terms f=identifier_ssim}url:#{http_uri}" }
      end
  end
end
