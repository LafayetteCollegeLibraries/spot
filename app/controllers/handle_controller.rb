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
    query = query_for_identifier(Spot::Identifier.new('hdl', params[:id]))
    result, _documents = repository.search(query)

    raise Blacklight::Exceptions::RecordNotFound if result.response['numFound'].zero?
    document = result.response['docs'].first

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
    { q: "{!terms f=#{identifier_solr_field}}#{id}",
      defType: 'lucene' }
  end
end
