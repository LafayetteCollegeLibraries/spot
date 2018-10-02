class HandleController < ApplicationController
  include Hydra::Catalog

  def show
    result, documents = search_results(q: "identifier_hdl_ssim:#{params[:id]}")

    raise Blacklight::Exceptions::RecordNotFound if documents.empty?

    # TODO: what happens if there are multiple responses?
    doc = result.response['docs'].first
    id = doc['id']
    controller = doc['has_model_ssim'].first.downcase.pluralize

    redirect_to controller: "hyrax/#{controller}", action: 'show', id: id
  end
end
