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

    # Send the user to the object if we can find one, otherwise sned a :not_found response
    # via Blacklight::Exceptions::RecordNotFound
    def show
      redirect_to document_params
    rescue => error
      log_error(error) unless error.is_a?(Blacklight::Exceptions::RecordNotFound)
      raise Blacklight::Exceptions::RecordNotFound
    end

    private

    def document_params
      # The only fields we'll need to generate a URL (or url_helper params) is are id and has_model_ssim.
      result, _documents = repository.search(q: "{!terms f=identifier_ssim}url:#{http_uri}", fl: ['id', 'has_model_ssim'], defType: 'lucene')
      document = result.response['docs']&.first

      raise Blacklight::Exceptions::RecordNotFound if document.nil?
      redirect_params_for(solr_document: document)
    end

    # Ensures that the URL we're searching for is http (and not https)
    #
    # @return [String]
    def http_uri
      URI.parse(params[:url]).tap { |url| url.scheme = 'http' }.to_s
    end

    def log_error(error)
      Rails.logger.debug(%([Spot::RedirectController] Received an #{error.class} while parsing url "#{params[:url]}" => "#{error.message}")) \
    end
  end
end
