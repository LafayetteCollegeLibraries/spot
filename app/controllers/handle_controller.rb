# frozen_string_literal: true
#
# Responsible for redirecting Handle requests to their associated items
class HandleController < ApplicationController
  include Hydra::Catalog
  include ::Spot::RedirectionHelpers

  # Searches for a Handle based on an +hdl:+ identifier.
  # Displays a 404 (via raised +Hyrax::ObjectNotFoundError+) if no item is found.
  def show
    result = Hyrax::SolrService.get("{!terms f=identifier_ssim}#{hdl_from_params}", defType: 'lucene')
    count = result.try(:[], 'response').try(:[], 'numFound')
    raise Hyrax::ObjectNotFoundError if count.nil? || count.zero?

    document = result['response']['docs'].first
    redirect_to redirect_params_for(solr_document: document)
  end

  private

  def hdl_from_params
    value = URI.decode_www_form_component(params[:id])
    Spot::Identifier.new('hdl', value).to_s
  end
end
