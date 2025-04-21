# frozen_string_literal: true
#
# Responsible for redirecting Handle requests to their associated items
class HandleController < ApplicationController
  include Hydra::Catalog
  include ::Spot::RedirectionHelpers

  # Searches for a Handle based on an +hdl:+ identifier.
  # Displays a 404 (via raised +Hyrax::ObjectNotFoundError+) if no item is found.
  def show
    results = Hyrax::SolrService.query("{!terms f=identifier_ssim}#{hdl_from_params}", defType: 'lucene')
    document = results.first
    raise Blacklight::Exceptions::RecordNotFound if document.nil?

    redirect_to redirect_params_for(solr_document: document)
  end

  private

  def hdl_from_params
    value = URI.decode_www_form_component(params[:id])
    Spot::Identifier.new('hdl', value).to_s
  end
end
