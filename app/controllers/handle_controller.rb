# frozen_string_literal: true
#
# Responsible for redirecting Handle requests to their associated items
class HandleController < ApplicationController
  include Hydra::Catalog
  include ::Spot::RedirectionHelpers

  # Searches for a Handle based on an +hdl:+ identifier.
  # Displays a 404 (via raised +Blacklight::Exceptions::RecordNotFound+
  # that is handled with +Hydra::Catalog+) if no item is found.
  def show
    query_opts = query_for_identifier(Spot::Identifier.new('hdl', params[:id]))
    service = Hyrax::SolrQueryService.new(query: [query_opts.delete(:q)])
    document = service.get(**query_opts)['response']['docs'].first

    raise Blacklight::Exceptions::RecordNotFound if document.nil?
    redirect_to redirect_params_for(solr_document: document)
  end

  private

  def id_from_params
    URI.decode(params[:id])
  end

  # @return [String]
  def identifier_solr_field
    'identifier_ssim'
  end

  # @param id [Spot::Identifier, #to_s] the identifier (with prefix)
  # @return [Hash<Symbol => String>]
  def query_for_identifier(id)
    { q: "{!terms f=identifier_ssim}#{id}", defType: 'lucene' }
  end
end
