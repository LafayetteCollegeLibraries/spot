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
  class RedirectController < ApplicationController
    include ::Hydra::Catalog
    include ::Spot::RedirectionHelpers

    def show
      # all that we need for this controller are the object's ID + Hydra Model
      query = solr_query_for_identifier.merge(fl: ['id', 'has_model_ssim'])
      result, _documents = repository.search(query)

      raise Blacklight::Exceptions::RecordNotFound if result.response['numFound'].zero?
      document = result.response['docs'].first

      redirect_to redirect_params_for(solr_document: document)
    rescue => error
      Rails.logger.debug(%([Spot::RedirectController] Received an #{error.class} while parsing url "#{params[:url]}" => "#{error.message}")) \
        unless error.is_a?(Blacklight::Exceptions::RecordNotFound)

      raise Blacklight::Exceptions::RecordNotFound
    end

    private

    # Ensures that the URL we're searching for is http (and not https)
    #
    # @return [String]
    def http_uri
      URI.parse(params[:url]).tap { |url| url.scheme = 'http' }.to_s
    end

    # @return [Hash<Symbol => String>]
    def solr_query_for_identifier
      { defType: 'lucene', q: "{!terms f=identifier_ssim}url:#{http_uri}" }
    end
  end
end
